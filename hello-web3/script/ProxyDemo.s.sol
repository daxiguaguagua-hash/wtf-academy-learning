// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {LogicV1} from "../src/LogicV1.sol";
import {ProxyDemo} from "../src/ProxyDemo.sol";

contract ProxyDemoScript is Script {
    LogicV1 public logicV1;
    ProxyDemo public proxy;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        logicV1 = new LogicV1();
        proxy = new ProxyDemo(address(logicV1));

        vm.stopBroadcast();
    }
}
