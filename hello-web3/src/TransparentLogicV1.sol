// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract TransparentLogicV1 {
    uint256 public number;
    address public owner;
    bool public initialized;

    function initialize(address _owner, uint256 _number) external {
        require(!initialized, "already initialized");
        owner = _owner;
        number = _number;
        initialized = true;
    }

    function setNumber(uint256 _number) external {
        require(msg.sender == owner, "not owner");
        number = _number;
    }

    function version() external pure virtual returns (string memory) {
        return "V1";
    }
}
