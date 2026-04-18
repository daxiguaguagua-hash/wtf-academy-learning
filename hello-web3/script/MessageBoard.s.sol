// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MessageBoard} from "../src/MessageBoard.sol";

contract MessageBoardScript is Script {
    MessageBoard public messageBoard;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        messageBoard = new MessageBoard();

        vm.stopBroadcast();
    }
}
