// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract Proxy {
    address public implementation;
    
    constructor(address _implementation) {
        implementation = _implementation;
    }

    fallback() external {
        (bool success, ) = implementation.call(msg.data);
        require(success);
    }

    function changeImplementation(address _implementation) external {
        implementation = _implementation;
    }

    function changeX(uint _x) external {
        Logic1(implementation).changeX(_x);
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