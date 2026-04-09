// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FallbackDemo} from "../src/FallbackDemo.sol";

contract FallbackDemoScript is Script {
    FallbackDemo public fallbackDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        fallbackDemo = new FallbackDemo();

        vm.stopBroadcast();
    }
}
