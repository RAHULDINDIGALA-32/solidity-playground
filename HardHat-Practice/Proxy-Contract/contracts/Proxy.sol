// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract Proxy {
    address public implementation;
    
    constructor(address _implementation) {
        implementation = _implementation;
    }
}