// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @title BasicNFT
 * @author Rahul Dindigala
 * @dev A simple implementation of an ERC721 Non-Fungible Token (NFT) using OpenZeppelin's ERC721 contract.
 */

contract BasicNFT is ERC721 {
    uint256 private s_tokenCounter;
    mapping(uint256 => string) private s_tokenIdToUri;

    constructor() ERC721("Dogie", "DOG") {
        s_tokenCounter = 0;
    }

    function mintNft(string memory tokenUri) public {
        s_tokenIdToUri[s_tokenCounter] = tokenUri;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter += 1;
    }

    function tokenURI(
        uint256 tokrnId
    ) public view override returns (string memory) {
        return s_tokenIdToUri[tokrnId];
    }
}
