// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe_NotOwner();

contract FundMe {

    using PriceConverter for uint256;
    // set minimum fund in USD
    uint public constant MINIMUM_FUND_IN_USD = 10e18;

    // track the sender address with respective fund sent
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // set the Owner
    address public immutable i_owner;

    // set the price feed address
    AggregatorV3Interface private priceFeed; 

    constructor(address priceFeedAddress){
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function fund() public payable  {

        require(msg.value.getConversionRate(priceFeed) >= MINIMUM_FUND_IN_USD, "Didn't send enough ETH (minimum fund is 10 USD)");
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

       (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        
        require(callSuccess, "Funds Transfer failed!!");
    }

    modifier onlyOwner() {
     //  require(msg.sender == i_owner, "Only Owner can withdraw funds!!");
     if(msg.sender != i_owner) {revert FundMe_NotOwner(); }
       _;
    }

    function getversion() public view returns (uint256){
        return priceFeed.version();
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
     }

     
}

