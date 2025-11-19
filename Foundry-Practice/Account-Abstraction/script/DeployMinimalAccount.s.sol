// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {HelperCofig} from "./HelperConfig.s.sol";

contract DeployMinimalAccount is Script {
    function run() external returns (HelperCofig.NetworkConfig memory, MinimalAccount) {
        return deoployMinimalAccount();
    }

    function deoployMinimalAccount() public returns (HelperCofig.NetworkConfig memory, MinimalAccount) {
        HelperCofig helperConfig = new HelperCofig();
        HelperCofig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast(config.account);
        MinimalAccount minimalAccount = new MinimalAccount(config.entryPoint);
        minimalAccount.transferOwnership(msg.sender);
        vm.stopBroadcast();

        return (config, minimalAccount);
    }
}
