// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    // set minimum fund in USD
    uint public constant MINIMUM_FUND_IN_USD = 10e18;

    // track the sender address with respective fund sent
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;

    // set the Owner
    address private immutable i_owner;

    // set the price feed address
    AggregatorV3Interface private s_priceFeed; 

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable  {

        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_FUND_IN_USD, "Didn't send enough ETH (minimum fund is 10 USD)");
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withDrawFunds() public onlyOwner {
      // require(msg.sender == i_owner, "Only owner can withdraw funds!!");

       for(uint256 i=0; i<s_funders.length; i++){
        address funder = s_funders[i];
        s_addressToAmountFunded[funder] =0;
       }

       s_funders = new address[](0);

       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        
        require(callSuccess, "Funds Transfer failed!!");
    }

     
    function CheaperWithDrawFunds() public onlyOwner { // gas optimized withdraw function
      // require(msg.sender == i_owner, "Only owner can withdraw funds!!");
      uint fundersLen = s_funders.length;

       for(uint256 i=0; i < fundersLen; i++){
        address funder = s_funders[i];
        s_addressToAmountFunded[funder] =0;
       }

       s_funders = new address[](0);

       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        
        require(callSuccess, "Funds Transfer failed!!");
    }

    modifier onlyOwner() {
     //  require(msg.sender == i_owner, "Only Owner can withdraw funds!!");
     if(msg.sender != i_owner) {revert FundMe__NotOwner(); }
       _;
    }

    function getversion() public view returns (uint256){
        return s_priceFeed.version();
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
     }

    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256){
        return s_addressToAmountFunded[fundingAddress];
     }

    function getFunder(uint256 index) external view returns (address){
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }

     
}

