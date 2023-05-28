// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FundMe.sol";
import "forge-std/console.sol";

contract Withdraw is Script {
    address mostRecentlyDeployedAddress;

    function setUp() public {
        if (block.chainid == 11155111) {
            mostRecentlyDeployedAddress = 0x9660e111e09e2400afBe5c39aBc3c01B05011391;
        } else {
            mostRecentlyDeployedAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;
        }
    }

    function run() external {
        vm.startBroadcast();
        FundMe(mostRecentlyDeployedAddress).cheaperWithdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }
}
