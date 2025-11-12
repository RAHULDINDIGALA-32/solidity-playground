// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ManualToken {
    bytes32 private constant NAME = "My Manual Token";
    bytes32 private constant SYMBOL = "MMT";
    uint8 private constant DECIMALS = 8;
    uint256 private s_totalSupply = 100 ether;

    mapping (address => uint256) private s_balances;

    /* Events */
    event Transfer(address from, address to, uint256 amount);

    /* Errors */
    error ManualToken__NotEnoughBalance(address owner, uint256 balance);

    // function name() public view returns (bytes32) {
    //     return (NAME);
    // }

    // function decimals() public view returns (uint8) {
    //     return (DECIMALS);
    // }

    // function totalSupply() public view returns (uint256) {
    //     return (s_totalSupply);
    // }

    function balanceOf(address _owner) public view returns (uint256) {
        returns (s_balances[_owner]);
    }

    function transfer(address _to, uint256 _amount) public {
        if(_amount > s_balances[msg.sender]){
            revert ManualToken__NotEnoughBalance(msg.sender, s_balances[msg.sender]);
        }

        uint256 balancesSumBeforeTransfer = s_balances[msg.sender] + s_balances[_to];
        s_balances[msg.sender] -= _amount;
        s_balances[_to] += _amount;
        require(balanceOf(msg.sender) + balanceOf(_to) == balancesSumBeforeTransfer);
        emit Transfer(msg.sender, _to, _amount);
    }

    
}
