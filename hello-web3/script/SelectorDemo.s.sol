// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SelectorDemo} from "../src/SelectorDemo.sol";

contract SelectorDemoScript is Script {
    SelectorDemo public selectorDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        selectorDemo = new SelectorDemo();

        vm.stopBroadcast();
    }
}
