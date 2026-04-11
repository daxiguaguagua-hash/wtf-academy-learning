// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TryCatchTargetDemo} from "../src/TryCatchTargetDemo.sol";
import {TryCatchDemo} from "../src/TryCatchDemo.sol";

contract TryCatchDemoScript is Script {
    TryCatchTargetDemo public targetDemo;
    TryCatchDemo public tryCatchDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        targetDemo = new TryCatchTargetDemo();
        tryCatchDemo = new TryCatchDemo();

        vm.stopBroadcast();
    }
}
