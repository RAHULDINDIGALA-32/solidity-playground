// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    // set minimum fund in USD
    uint public constant MINIMUM_FUND_IN_USD = 10e18;

    // track the sender address with respective fund sent
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // set the Owner
    address public immutable i_owner;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable  {

        require(msg.value.getConversionRate() >= MINIMUM_FUND_IN_USD, "Didn't send enough ETH (minimum fund is 10 USD)");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withDrawFunds() public onlyOwner {
      // require(msg.sender == i_owner, "Only owner can withdraw funds!!");

       for(uint256 i=0; i<funders.length; i++){
        address funder = funders[i];
        addressToAmountFunded[funder] =0;
       }

       funders = new address[](0);

       // transfer the funds 
       // 1.transfer ( with 2300 gas limit, if exceed txn fails, returns error )
       //payable(msg.sender).transfer(address(this).balance);
       // 2. send ( with 2300 gas limit, if exceed txn fails, returns bool )
      // bool isTransferSuccess = payable(msg.sender).send(address(this).balance);
       // 3. call ( no gas limit, returns (bool cakllSuccess, bytes dataReturned) )
       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        
        require(callSuccess, "Funds Transfer failed!!");
    }

    modifier onlyOwner() {
     //  require(msg.sender == i_owner, "Only Owner can withdraw funds!!");
     if(msg.sender != i_owner) {revert NotOwner(); }
       _;
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
     }

     
}

