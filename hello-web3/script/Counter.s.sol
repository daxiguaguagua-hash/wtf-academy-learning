// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {HelloWeb3} from "../src/Counter.sol";

contract CounterScript is Script {
    HelloWeb3 public helloWeb3;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        helloWeb3 = new HelloWeb3();

        vm.stopBroadcast();
    }
}
