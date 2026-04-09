// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FallbackDemoV2} from "../src/FallbackDemoV2.sol";

/**
 * 这是合约的部署脚本
 */
contract FallbackDemoV2Script is Script {
    FallbackDemoV2 public fallbackDemoV2;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fallbackDemoV2 = new FallbackDemoV2();

        vm.stopBroadcast();
    }
}
