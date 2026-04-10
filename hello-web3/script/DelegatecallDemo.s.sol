// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {LogicDemo} from "../src/LogicDemo.sol";
import {DelegatecallDemo} from "../src/DelegatecallDemo.sol";

contract DelegatecallDemoScript is Script {
    LogicDemo public logicDemo;
    DelegatecallDemo public delegatecallDemo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // 先部署目标合约
        logicDemo = new LogicDemo();
        // 然后才是调用方合约
        delegatecallDemo = new DelegatecallDemo();

        vm.stopBroadcast();
    }
}
