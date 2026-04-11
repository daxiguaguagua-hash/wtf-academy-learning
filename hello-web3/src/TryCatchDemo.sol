// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TryCatchTargetDemo} from "./TryCatchTargetDemo.sol";

contract TryCatchDemo {
    uint256 public lastResult;
    string public lastMessage;
    bool public lastSuccess;

    function trySetNumber(address targetAddress, uint256 newNumber) external {
        TryCatchTargetDemo target = TryCatchTargetDemo(targetAddress);

        try target.setNumber(newNumber) returns (uint256 result) {
            lastResult = result;
            lastMessage = "success";
            lastSuccess = true;
        } catch {
            lastResult = 0;
            lastMessage = "failed";
            lastSuccess = false;
        }
    }
}
