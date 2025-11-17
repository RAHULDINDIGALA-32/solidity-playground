// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract MerkleAirdrop {
    bytes32 private immutable _MERKLE_Root;
    IERC20 private immutable _AIRDROP_TOKEN;

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        _MERKLE_Root = merkleRoot;
        _AIRDROP_TOKEN = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {}
}
