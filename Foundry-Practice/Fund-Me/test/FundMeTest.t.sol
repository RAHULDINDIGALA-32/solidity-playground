// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
 
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function  testMinimumFundIsTenUsd() public view {
        assertEq(fundMe.MINIMUM_FUND_IN_USD(), 10e18);
    }

    function testOwnerIsmsgSender() public view {
       // assertEq(fundMe.i_owner(), address(this));
       assertEq(fundMe.i_owner(), msg.sender);
    }

    function testGetVersion() public view{
        assertEq(fundMe.getversion(), 4);
    }


}