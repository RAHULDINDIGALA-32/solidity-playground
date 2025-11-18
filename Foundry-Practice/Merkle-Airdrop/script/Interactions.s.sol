// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {SomeToken} from "../src/SomeToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ClaimAirdrop is Script {
    address private constant CLAIMING_ADDRESS = 0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd;
    uint256 private constant CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 private constant PROOF_ONE = 0x4fd31fee0e75780cd67704fbc43caee70fddcaa43631e2e1bc9fb233fada2394;
    bytes32 private constant PROOF_TWO = 0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2;
    bytes32[] proof = [PROOF_ONE, PROOF_TWO];
    bytes private constant SIGNATURE =
        hex"3de28ddc637b3743cf2f77469b344480eea076cbcb68f653f948628fb77e276627c259cc5657d14582c643f8cf0080cde3f52c796a3eb554ae21607bf70235aa1b";

    error InteractionsScript__InvalidSignatureLength();

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        vm.startBroadcast();
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory signature) public view returns (uint8 v, bytes32 r, bytes32 s) {
        if (signature.length != 65) {
            revert InteractionsScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }
}

