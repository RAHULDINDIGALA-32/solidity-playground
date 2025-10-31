// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
 
contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("testUser");
    uint256 constant SEND_VALUE = 0.5 ether;
    uint256 constant STARTING_BALANCE = 100 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function  testMinimumFundIsTenUsd() public view {
        assertEq(fundMe.MINIMUM_FUND_IN_USD(), 10e18);
    }

    function testOwnerIsmsgSender() public view {
       // assertEq(fundMe.i_owner(), address(this));
       assertEq(fundMe.getOwner(), msg.sender);
    }

    function testGetVersion() public view{
        assertEq(fundMe.getversion(), 4);
    }
    
    function testFundFailsWithoutEnoughETH()  public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }


    function testFundUpdatesFunderDataStructure() public funded(){
        uint256 amountFunded =fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public funded {
       address funder  = fundMe.getFunder(0);
        assertEq(funder, USER);
    }    

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withDrawFunds();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withDrawFunds();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Gas Used:", gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMebalance = address(fundMe).balance;
        
        assertEq(endingFundMebalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMebalance);
    }

    function testWithDrawWithMultipleFunders() public {
       // Arrange
        uint256 numberOfFunders=10;
        uint160 startingFunderIndex =1;

        for(uint160 i= startingFunderIndex; i<=numberOfFunders; i++){
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
          }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMebalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withDrawFunds();

        // Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + startingFundMebalance);
    }
}