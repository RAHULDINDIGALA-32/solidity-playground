// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {SomeToken} from "../../src/SomeToken.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {ZkSyncChainChecker} from "foundry-devops/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public airdrop;
    SomeToken public token;

    bytes32 public root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    bytes32 public proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 public proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proofOne, proofTwo];

    uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public constant AMOUNT_TO_MINT = 5 * AMOUNT_TO_CLAIM;
    address validUser;
    uint256 validUserPrivateKey;
    address randomUser;
    uint256 randomUserPrivateKey;
    address gasPayer;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new SomeToken();
            airdrop = new MerkleAirdrop(root, token);
            token.mint(token.owner(), AMOUNT_TO_MINT);
            token.transfer(address(airdrop), AMOUNT_TO_MINT);
        }

        (validUser, validUserPrivateKey) = makeAddrAndKey("user");
        (randomUser, randomUserPrivateKey) = makeAddrAndKey("random-user");
        gasPayer = makeAddr("gasPayer");
    }

    function testValidUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(validUser);
        bytes32 digest = airdrop.getMessageHash(validUser, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(validUserPrivateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(validUser, AMOUNT_TO_CLAIM, proof, v, r, s);

        console.log("Claimed token amount: ", token.balanceOf(validUser) - startingBalance);
    }

    function testRevertOnInvalidUserClaim() public {
        bytes32 digest = airdrop.getMessageHash(randomUser, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(randomUserPrivateKey, digest);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        vm.prank(randomUser);
        airdrop.claim(randomUser, AMOUNT_TO_CLAIM, proof, v, r, s);
    }
}

