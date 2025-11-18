// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {SomeToken} from "../src/SomeToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    uint256 private _claimerCount = 4;
    bytes32 private _merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private _amountToAirdrop = 25 * 1e18;
    uint256 private _amountToMint = _claimerCount * _amountToAirdrop;

    function run() external returns (MerkleAirdrop, SomeToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, SomeToken) {
        vm.startBroadcast();
        SomeToken token = new SomeToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), _amountToMint);
        token.transfer(address(airdrop), _amountToMint);
        vm.stopBroadcast();

        return (airdrop, token);
    }
}
