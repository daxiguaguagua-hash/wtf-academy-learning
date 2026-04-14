// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {UUPSLogicV1} from "./UUPSLogicV1.sol";

contract UUPSLogicV2 is UUPSLogicV1 {
    function increment() external {
        require(msg.sender == owner, "not owner");
        number += 1;
    }

    function version() external pure override returns (string memory) {
        return "UUPS V2";
    }
}
