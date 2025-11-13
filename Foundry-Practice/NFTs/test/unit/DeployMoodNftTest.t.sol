// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployMoodNFT} from "../../script/DeployMoodNFT.s.sol";

contract DeployMoodNftTest is Test {
    DeployMoodNFT deployer;

    function setUp() public {
        deployer = new DeployMoodNFT();
    }

    function testDeployMoodNft() public {
        deployer.run();
    }

    function testSvgToImageUri() public view {
        string
            memory svg = "<svg><rect width='100' height='100' fill='blue'/>Hello there!! I'm Rahul Dindigala here.</svg>";
        string
            memory expectedUri = "data:image/svg+xml;base64,PHN2Zz48cmVjdCB3aWR0aD0nMTAwJyBoZWlnaHQ9JzEwMCcgZmlsbD0nYmx1ZScvPkhlbGxvIHRoZXJlISEgSSdtIFJhaHVsIERpbmRpZ2FsYSBoZXJlLjwvc3ZnPg==";
        string memory imageUri = deployer.svgToImageUri(svg);
        console.log("Image URI:", imageUri);
        assert(bytes(imageUri).length > 0);
        assert(keccak256(bytes(imageUri)) == keccak256(bytes(expectedUri)));
    }
}
