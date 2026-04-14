// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UUPSLogicV1 {
    bytes32 internal constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

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

    function upgradeTo(address newImplementation) external {
        require(msg.sender == owner, "not owner");
        require(newImplementation != address(0), "implementation is zero");
        _setImplementation(newImplementation);
    }

    function version() external pure virtual returns (string memory) {
        return "UUPS V1";
    }

    function _setImplementation(address newImplementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, newImplementation)
        }
    }
}
