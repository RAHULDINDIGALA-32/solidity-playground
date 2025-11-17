// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    /* type declarations */
    using SafeERC20 for IERC20;

    /* State Variables */
    bytes32 private immutable _MERKLE_ROOT;
    IERC20 private immutable _AIRDROP_TOKEN;
    mapping(address claimer => bool claimed) private _hasClaimed;

    /* Events */
    event Claim(address user, uint256 amount);

    /* Errors */
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop_AlreadyClaimed();

    /* Functions */
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        _MERKLE_ROOT = merkleRoot;
        _AIRDROP_TOKEN = airdropToken;
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (_hasClaimed[account]) {
            revert MerkleAirdrop_AlreadyClaimed();
        }
        // Here in merkle tree proof, we hash leaf twice to avoid collisons among leafs having same hash (also prevents "Second pre-image attack")
        bytes32 leafHash = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, _MERKLE_ROOT, leafHash)) {
            revert MerkleAirdrop__InvalidProof();
        }

        _hasClaimed[account] = true;
        emit Claim(account, amount);
        _AIRDROP_TOKEN.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return _MERKLE_ROOT;
    }

    function getAirdroptoken() external view returns (IERC20) {
        return _AIRDROP_TOKEN;
    }
}
