// SPDX-LICENSE-IDENTIFIER: MIT
pragma solidity ^0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "lib/v2-periphery/contracts/interfaces/IERC20.sol";
import {IWETH} from "lib/v2-periphery/contracts/interfaces/IWETH.sol";
import {IUniswapV2Factory} from "lib/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "lib/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {DAI, WETH, UNISWAP_V2_PAIR_DAI_WETH, UNISWAP_V2_FACTORY} from "../src/Constants.sol";
import {ERC20} from "../src/ERC20.sol";

contract UniswapV2FactoryTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

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
}
