// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {StorageSlot} from "./StorageSlot.sol";

contract Proxy {
    //address public implementation;
    uint public x;
    
    constructor(address _implementation) {
        //implementation = _implementation;
        StorageSlot.getAddressSlot(keccak256("my.proxy.implementation")).value = _implementation;

    }

    fallback() external {
       // (bool success, ) = implementation.call(msg.data);
       (bool success, ) = StorageSlot.getAddressSlot(keccak256("my.proxy.implementation")).value.delegatecall(msg.data);
        require(success);
    }

    function changeImplementation(address _implementation) external {
       // implementation = _implementation;
       StorageSlot.getAddressSlot(keccak256("my.proxy.implementation")).value = _implementation;
    }

    function changeX(uint _x) external {
        // Logic1(implementation).changeX(_x);
        Logic1(StorageSlot.getAddressSlot(keccak256("my.proxy.implementation")).value).changeX(_x);
    }
}


contract Logic1 {
    uint public x;

    function changeX(uint _x) external {
        x = _x;
    }
}

contract Logic2 {
    uint public x;

    function changeX(uint _x) external {
        x = _x*2;
    }

    function tripleX(uint _x) external {
        x = _x*3;
    }
}