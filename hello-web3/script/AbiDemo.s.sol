// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {AbiDemo} from "../src/AbiDemo.sol";

contract AbiDemoScript is Script {
    AbiDemo public abiDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        abiDemo = new AbiDemo();

        vm.stopBroadcast();
    }
}
