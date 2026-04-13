// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {TransparentLogicV1} from "./TransparentLogicV1.sol";

contract TransparentLogicV2 is TransparentLogicV1 {
    function increment() external {
        require(msg.sender == owner, "not owner");
        number += 1;
    }

    function version() external pure override returns (string memory) {
        return "V2";
    }
}
