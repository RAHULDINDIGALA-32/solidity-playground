// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title MoodNFT
 * @author Rahul Dindigala
 * @dev A simple ERC721 contract that allows users to mint NFTs representing their mood.
 */
contract MoodNFT is ERC721 {
    enum Mood {
        HAPPY,
        SAD
    }

    uint256 private tokenCounter;
    //mapping(uint256 => string) private tokenIdToUri;
    string private sadSvgImageUri;
    string private happySvgImageUri;
    mapping(uint256 => Mood) private tokenIdToMood;

    /* Errors */
    error NotAuthorizedToFlipMood();

    constructor(
        string memory _sadSvgImageUri,
        string memory _happySvgImageUri
    ) ERC721("MoodNFT", "MOOD") {
        tokenCounter = 0;
        sadSvgImageUri = _sadSvgImageUri;
        happySvgImageUri = _happySvgImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, tokenCounter);
        tokenIdToMood[tokenCounter] = Mood.HAPPY;
        tokenCounter += 1;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageURI = tokenIdToMood[tokenId] == Mood.HAPPY
            ? happySvgImageUri
            : sadSvgImageUri;

        string memory tokenMetadataInBytes = string(
            abi.encodePacked(
                '{"name": "',
                name(),
                '", "description": "An NFT that reflects the mood of the owner.", "attributes": [{"trait_type": "mood", "value": 100}], "image": "',
                imageURI,
                '"}'
            )
        );

        string memory tokenMetadata = Base64.encode(
            bytes(tokenMetadataInBytes)
        );

        return string(abi.encodePacked(_baseURI(), tokenMetadata));
    }

    function flipMood(uint256 tokenId) public {
        // only owner can flip the mood
        if (!_isAuthorized(msg.sender, msg.sender, tokenId)) {
            revert NotAuthorizedToFlipMood();
        }

        if (tokenIdToMood[tokenId] == Mood.HAPPY) {
            tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }
}
