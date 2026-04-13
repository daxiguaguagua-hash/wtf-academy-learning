// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ProxyDemo {
    uint256 public number;
    address public implementation;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function upgradeTo(address _implementation) public {
        implementation = _implementation;
    }

    receive() external payable {}

    fallback() external payable {
        address impl = implementation;

        assembly {
            // 把用户原始调用数据复制出来
            calldatacopy(0, 0, calldatasize())

            // 转发给 implementation
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)

            // 把返回值复制回来
            returndatacopy(0, 0, returndatasize())

            // 把结果原样返回给用户
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
