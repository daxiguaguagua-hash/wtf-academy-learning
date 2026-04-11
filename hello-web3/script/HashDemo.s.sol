// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {HashDemo} from "../src/HashDemo.sol";

contract HashDemoScript is Script {
    HashDemo public hashDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        hashDemo = new HashDemo();

        vm.stopBroadcast();
    }
}
