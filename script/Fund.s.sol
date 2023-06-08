// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract Fund is Script {
    uint256 SEND_VALUE = 0.1 ether;
    // * this variable will get the address manual way.
    address mostRecentlyDeployedAddress;

    function setUp() public {
        if (block.chainid == 11155111) {
            mostRecentlyDeployedAddress = 0x9660e111e09e2400afBe5c39aBc3c01B05011391;
        } else {
            mostRecentlyDeployedAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        FundMe(mostRecentlyDeployed).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
}
