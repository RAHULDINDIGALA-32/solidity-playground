// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract Smile {
    string private smiley;

    event SmileyChanged(string indexed oldSmiley, string newSmiley);

    constructor() {
        smiley = unicode"😊";
        emit SmileyChanged("", smiley);
    }

    function getSmiley() public view returns (string memory) {
        return smiley;
    }

    function setSmiley(string memory _smiley) public {
        string memory oldSmiley = smiley;
        smiley = _smiley;
        emit SmileyChanged(oldSmiley, smiley);
    }
}