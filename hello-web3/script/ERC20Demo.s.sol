// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC20Demo} from "../src/ERC20Demo.sol";

contract ERC20DemoScript is Script {
    ERC20Demo public token;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new ERC20Demo(1000);

        vm.stopBroadcast();
    }
}
