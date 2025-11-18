// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    /* type declarations */
    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /* State Variables */
    bytes32 private immutable _MERKLE_ROOT;
    IERC20 private immutable _AIRDROP_TOKEN;
    mapping(address claimer => bool claimed) private _hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    /* Events */
    event Claim(address user, uint256 amount);

    /* Errors */
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop_AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    /* Functions */
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        _MERKLE_ROOT = merkleRoot;
        _AIRDROP_TOKEN = airdropToken;
    }

    /* External Functions */
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        if (_hasClaimed[account]) {
            revert MerkleAirdrop_AlreadyClaimed();
        }
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
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

    /* Public Functions */
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    /* Internal Functions */
    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}
