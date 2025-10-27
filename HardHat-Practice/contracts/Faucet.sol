//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// sepolia deployed this contract address: 0xc1e7FD7eA9A428d082FeF7Bf610217e858B917dd
contract Faucet {
  
  function withdraw(uint _amount) public {
    // users can only withdraw .1 ETH at a time
    require(_amount <= 100000000000000000);
    payable(msg.sender).transfer(_amount);
  }

  // fallback function
  receive() external payable {}
}
