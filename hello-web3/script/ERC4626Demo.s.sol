// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ERC4626Demo} from "../src/ERC4626Demo.sol";

contract ERC4626DemoScript is Script {
    ERC4626Demo public demo;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        demo = new ERC4626Demo();

        vm.stopBroadcast();
    }
}
