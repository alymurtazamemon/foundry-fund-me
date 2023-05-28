// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/src/Script.sol";
import "./HelperConfig.s.sol";
import "../src/FundMe.sol";

contract DeployFundMe is Script {
    address priceFeed;

    function setUp() public {
        HelperConfig helperConfig = new HelperConfig(); // This comes with our mocks!
        priceFeed = helperConfig.activeNetworkConfig();
    }

    function run() public {
        vm.startBroadcast();
        new FundMe(priceFeed);
        vm.stopBroadcast();
    }
}
