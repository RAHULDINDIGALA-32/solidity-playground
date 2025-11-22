// SPDX-LICENSE-IDENTIFIER: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "lib/v2-periphery/contracts/interfaces/IERC20.sol";
import {IWETH} from "lib/v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, UNISWAP_V2_PAIR_DAI_WETH, UNISWAP_V2_FACTORY, UNISWAP_V2_ROUTER_02} from "../src/Constants.sol";
import {ERC20} from "../src/ERC20.sol";

contract UniswapV2FactoryTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);
    IUniswapV2Router02 private constant router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pairDaiWeth = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    address private constant user = address(100);
    address private token0;
    address private token1;

    error UniswapV2FactoryTest__InvalidToken();
    error UniswapV2FactoryTest__NotPair();
    error UniswapV2FactoryTest__NotSender();

    function setUp() public {
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        weth.approve(address(this), type(uint256).max);
        vm.stopPrank();

        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        dai.approve(address(this), type(uint256).max);
        vm.stopPrank();

        token0 = pairDaiWeth.token0();
        token1 = pairDaiWeth.token1();
    }

    function testCreatePair() public {
        ERC20 token = new ERC20("Test Token", "TSTT", 18);
        address pair = factory.createPair(address(token), WETH);

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (address(token) < WETH) {
            assertEq(token0, address(token), "token 0");
            assertEq(token1, WETH, "token 1");
        } else {
            assertEq(token0, WETH, "token 0");
            assertEq(token1, address(token), "token 1");
        }
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);
        (,, uint256 liquidity) = router.addLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            amountADesired: 1000000 * 1e18,
            amountBDesired: 100 * 1e18,
            amountAMin: 1,
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
        });

        pairDaiWeth.approve(address(router), liquidity);

        (uint256 amountA, uint256 amountB) = router.removeLiquidity(DAI, WETH, liquidity, 1, 1, user, block.timestamp);
        vm.stopPrank();

        console2.log("DAI", amountA);
        console2.log("WETH", amountB);

        assert(pairDaiWeth.balanceOf(user) == 0);
    }

    function testFlashSwap() external {
        address token = WETH;
        uint256 amount = 100 * 1e18;

        if (token != token0 && token != token1) {
            revert UniswapV2FactoryTest__InvalidToken();
        }

        (uint256 amount0Out, uint256 amount1Out) = token == token0 ? (amount, uint256(0)) : (uint256(0), amount);

        bytes memory data = abi.encode(token, user);

        vm.prank(user);
        pairDaiWeth.swap(amount0Out, amount1Out, address(this), data);
    }

    function uniswapV2Call(address sender, uint256 amount0, uint256 amount1, bytes calldata data) external {
        if (msg.sender != address(pairDaiWeth)) {
            revert UniswapV2FactoryTest__NotPair();
        }

        if (sender != user) {
            revert UniswapV2FactoryTest__NotSender();
        }

        (address token, address caller) = abi.decode(data, (address, address));

        uint256 amount = token == token0 ? amount0 : amount1;

        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;

        IERC20(token).transferFrom(caller, address(this), fee);
        IERC20(token).transfer(address(pairDaiWeth), amountToRepay);
    }
}
