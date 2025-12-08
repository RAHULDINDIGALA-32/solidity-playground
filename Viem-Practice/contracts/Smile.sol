// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Smile {
    string private smiley;

    constructor() {
        smiley = unicode"😊";
    }

    function getSmiley() public view returns (string memory) {
        return smiley;
    }

    function setSmiley(string memory _smiley) public {
        smiley = _smiley;
    }
}