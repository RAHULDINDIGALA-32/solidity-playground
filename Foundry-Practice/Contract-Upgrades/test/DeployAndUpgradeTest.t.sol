// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    address public OWNER = makeAddr("owner");

    address public proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run();
    }

    function testProxyStartsAsBoxv1() public {
        vm.expectRevert();
        BoxV1(proxy).setNumber(10);
    }

    function testUpgrade() public {
        BoxV2 box2 = new BoxV2();

        upgrader.upgradeBox(proxy, address(box2));

        uint256 expectedValue = 2;
        assert(expectedValue == BoxV2(proxy).version());

        BoxV2(proxy).setNumber(10);
        assert(BoxV2(proxy).getNumber() == 10);
    }
}
