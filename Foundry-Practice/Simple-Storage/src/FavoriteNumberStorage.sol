// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FavoriteNumberStorage {
    bytes32 public author = "rahul dindigala";
    uint256 favoriteNumber = 3;

    struct Person {
        string name;
        uint256 favoriteNumber;
    }

    Person[] public peopleList;

    mapping(string => uint256) public findFavoriteNumberByName;

    function setMyFavoriteNumber(uint256 _favoriteNumber) public virtual {
        favoriteNumber = _favoriteNumber;
    }

    function getMyFavoriteNumber() public view returns (uint256) {
        return favoriteNumber;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        peopleList.push(Person({name: _name, favoriteNumber: _favoriteNumber}));
        findFavoriteNumberByName[_name] = _favoriteNumber;
    }
}
