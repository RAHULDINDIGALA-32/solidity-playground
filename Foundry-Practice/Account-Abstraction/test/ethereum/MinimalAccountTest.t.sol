// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimalAccount} from "../../script/DeployMinimalAccount.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    ERC20Mock usdc;

    uint256 private constant AMOUNT = 1e18;
    address randomUser = makeAddr("random-user");

    function setUp() public {
        DeployMinimalAccount deployer = new DeployMinimalAccount();
        (helperConfig, minimalAccount) = deployer.run();
        usdc = new ERC20Mock();
    }

    function testOwnerCanExecuteCommands() public {
        // Arrange
        assert(usdc.balanceOf(address(minimalAccount)) == 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(destination, value, functionData);
        // Assert
        assert(usdc.balanceOf(address(minimalAccount)) == AMOUNT);
    }

    function testRevertOnNonOnwerExecuteCommand() public {
        // Arrange
        assert(usdc.balanceOf(address(minimalAccount)) == 0);
        address destination = address(usdc);
        uint256 value = 0;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);
        // Act & Assert
        vm.prank(randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__NotFromEntryPointOrOwner.selector);
        minimalAccount.execute(destination, value, functionData);
    }
}
