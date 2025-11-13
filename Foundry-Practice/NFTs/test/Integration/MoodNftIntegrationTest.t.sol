// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MoodNFT} from "../../src/MoodNFT.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

contract MoodNftIntegrationTest is Test {
    MoodNFT moodNft;
    DeployMoodNFT deployer;

    address public user = makeAddr("user");

    function setUp() public {
        deployer = new DeployMoodNFT();
        moodNft = deployer.run();
    }

    function testMintNft() public {
        vm.prank(user);
        moodNft.mintNft();
        console.log("Token URI:", moodNft.tokenURI(0));
        assert(moodNft.ownerOf(0) == user);
    }

    function testFlipTokenMoodToSad() public {
        vm.prank(user);
        moodNft.mintNft();
        string memory happyTokenUri = moodNft.tokenURI(0);
        console.log("Token URI before flip:", happyTokenUri);
        // Flip the mood
        vm.prank(user);
        moodNft.flipMood(0);
        string memory sadTokenUri = moodNft.tokenURI(0);
        console.log("Token URI after flip:", sadTokenUri);

        assert(
            keccak256(bytes(happyTokenUri)) != keccak256(bytes(sadTokenUri))
        );
    }
}
