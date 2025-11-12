// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "script/DeployOurToken.s.sol";
import {OurToken} from "src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    uint256 public constant STARTING_BALANCE = 1000 ether;
    uint256 public constant INITIAL_SUPPLY = 100000 ether;

    address suresh = makeAddr("suresh");
    address ramesh = makeAddr("ramesh");
    address anil = makeAddr("anil");

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // function setUp() public {
    //     deployer = new DeployOurToken();
    //     ourToken = deployer.run();

    //     // Get the address that received the initial supply in DeployOurToken
    //     address owner = vm.addr(1); // same key used in startBroadcast()

    //     // prank as the owner to transfer tokens to suresh
    //     vm.prank(owner);
    //     // Fund suresh with some tokens from deployer
    //     ourToken.transfer(suresh, STARTING_BALANCE);
    // }

    function setUp() public {
        ourToken = new OurToken(INITIAL_SUPPLY);

        // Fund suresh with some tokens
        ourToken.transfer(suresh, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                               METADATA
    //////////////////////////////////////////////////////////////*/

    function testNameAndSymbol() public view {
        assertEq(ourToken.name(), "OurToken");
        assertEq(ourToken.symbol(), "OT");
        assertEq(ourToken.decimals(), 18);
    }

    /*//////////////////////////////////////////////////////////////
                               SUPPLY
    //////////////////////////////////////////////////////////////*/

    function testTotalSupplyIsCorrect() public view {
        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    function testTotalSupplyUnchangedAfterTransfers() public {
        vm.prank(suresh);
        ourToken.transfer(ramesh, 10 ether);

        assertEq(ourToken.totalSupply(), INITIAL_SUPPLY);
    }

    /*//////////////////////////////////////////////////////////////
                              TRANSFERS
    //////////////////////////////////////////////////////////////*/

    function testSureshBalance() public view {
        assertEq(ourToken.balanceOf(suresh), STARTING_BALANCE);
    }

    function testTransferBetweenUsers() public {
        uint256 amount = 5 ether;
        uint256 sureshBalanceBefore = ourToken.balanceOf(suresh);
        uint256 rameshBalanceBefore = ourToken.balanceOf(ramesh);

        vm.prank(suresh);
        ourToken.transfer(ramesh, amount);

        assertEq(ourToken.balanceOf(suresh), sureshBalanceBefore - amount);
        assertEq(ourToken.balanceOf(ramesh), rameshBalanceBefore + amount);
    }

    function testTransferRevertsIfInsufficientBalance() public {
        uint256 balance = ourToken.balanceOf(ramesh);
        uint256 tooMuch = balance + 1;

        vm.prank(ramesh);
        vm.expectRevert();
        ourToken.transfer(suresh, tooMuch);
    }

    function testTransferToZeroAddressReverts() public {
        vm.prank(suresh);
        vm.expectRevert();
        ourToken.transfer(address(0), 10 ether);
    }

    function testTransferZeroAmountSucceeds() public {
        vm.prank(suresh);
        ourToken.transfer(ramesh, 0);

        // No balances should change
        assertEq(ourToken.balanceOf(suresh), STARTING_BALANCE);
        assertEq(ourToken.balanceOf(ramesh), 0);
    }

    /*//////////////////////////////////////////////////////////////
                             ALLOWANCES
    //////////////////////////////////////////////////////////////*/

    function testApproveAndTransferFromFlow() public {
        uint256 initialAllowance = 1000;
        uint256 transferAmount = 500;

        vm.prank(suresh);
        ourToken.approve(ramesh, initialAllowance);

        vm.prank(ramesh);
        ourToken.transferFrom(suresh, ramesh, transferAmount);

        assertEq(
            ourToken.allowance(suresh, ramesh),
            initialAllowance - transferAmount
        );
        assertEq(ourToken.balanceOf(ramesh), transferAmount);
    }

    function testTransferFromRevertsIfAllowanceExceeded() public {
        vm.prank(suresh);
        ourToken.approve(ramesh, 100);

        vm.prank(ramesh);
        vm.expectRevert();
        ourToken.transferFrom(suresh, ramesh, 200);
    }

    function testApproveZeroAddressReverts() public {
        vm.prank(address(0));
        vm.expectRevert();
        ourToken.approve(ramesh, 100);
    }

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    function testTransferEmitsEvent() public {
        vm.prank(suresh);
        vm.expectEmit(true, true, false, true);
        emit Transfer(suresh, ramesh, 1 ether);
        ourToken.transfer(ramesh, 1 ether);
    }

    function testApprovalEmitsEvent() public {
        vm.prank(suresh);
        vm.expectEmit(true, true, false, true);
        emit Approval(suresh, ramesh, 500);
        ourToken.approve(ramesh, 500);
    }

    /*//////////////////////////////////////////////////////////////
                             SECURITY
    //////////////////////////////////////////////////////////////*/

    function testNoMintFunctionCallable() public {
        // Ensure _mint is internal only
        // If user tries to call a non-existent mint, it should revert
        bytes4 selector = bytes4(keccak256("mint(address,uint256)"));
        (bool success, ) = address(ourToken).call(
            abi.encodeWithSelector(selector, suresh, 1000)
        );
        assertFalse(success);
    }

    /*//////////////////////////////////////////////////////////////
                             DEPLOYMENT
    //////////////////////////////////////////////////////////////*/

    // function testInitialSupplyAssignedToDeployer() public view {
    //     assertEq(
    //         ourToken.balanceOf(msg.sender),
    //         ourToken.totalSupply() - STARTING_BALANCE
    //     );
    // }
}
