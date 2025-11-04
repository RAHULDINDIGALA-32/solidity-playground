// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Token {
    uint256 public totalSupply;
    string public name = "First Local Coin";
    string public symbol = "FLC";
    uint8 public decimals = 18;

    mapping(address => uint256) public balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    constructor() {
        totalSupply = 1000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256 balance) {
        balance = balances[_owner];
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        if (balances[msg.sender] < _value) {
            revert("Not enough balance!!");
        }

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        success = true;
        emit Transfer(msg.sender, _to, _value);
    }
}
