// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {FavoriteNumberStorage} from "../src/FavoriteNumberStorage.sol";

contract DeployFavoriteNumberStorage is Script {
    function run() external returns (FavoriteNumberStorage) {
        vm.startBroadcast();
        FavoriteNumberStorage favoriteNumberStorage = new FavoriteNumberStorage();
        vm.stopBroadcast();

        return favoriteNumberStorage;
    }
}

