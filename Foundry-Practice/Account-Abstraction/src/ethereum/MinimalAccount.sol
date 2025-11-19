// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    /* State Variables */
    IEntryPoint private immutable _ENTRY_POINT;

    /* Errors */
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes result);

    /* Modifiers */
    modifier requireFromEntryPoint() {
        if (msg.sender != address(_ENTRY_POINT)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(_ENTRY_POINT) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    /* Functions */
    constructor(address entryPoint) Ownable(msg.sender) {
        _ENTRY_POINT = IEntryPoint(entryPoint);
    }

    /* External Functions */

    // Here a signature is valid, if it is the Minimal Account owner
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        requireFromEntryPoint
        returns (uint256 validationData)
    {
        validationData = _validateSignature(userOp, userOpHash);
        // usually nonce is tracked by EntryPoint.sol
        //_validateNonce();
        _payPreFund(missingAccountFunds);
    }

    function execute(address destination, uint256 value, bytes calldata functionData)
        external
        requireFromEntryPointOrOwner
    {
        (bool success, bytes memory result) = payable(destination).call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    /* Getters */
    function getEntryPoint() external view returns (address) {
        return address(_ENTRY_POINT);
    }

    /* Internal FUnctions */
    function _payPreFund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            require(success);
        }
    }

    /**
     *
     * @param userOp user opeartion packed in PackerUserOperation struct format
     * @param userOpHash EIP-191 version of the signed hash
     */
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature);

        if (signer != owner()) return SIG_VALIDATION_FAILED;
        return SIG_VALIDATION_SUCCESS;
    }
}
