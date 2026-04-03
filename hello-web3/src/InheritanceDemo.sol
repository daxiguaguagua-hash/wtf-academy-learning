// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Parent {
    uint256 public number = 100;

    function getNumber() public view returns (uint256) {
        return number;
    }
}

/**
 * @notice Child 继承了 Parent，Child 就拥有了 Parent 的所有状态变量和函数
 * @notice Inheritance 是 Solidity 里非常重要的一个特性，很多设计模式都离不开它，比如常见的 Ownable 模式（权限管理），
 * @notice 还有一些复杂的合约框架（如 OpenZeppelin）也大量使用了 Inheritance 来实现功能模块化和代码复用
 */
contract Child is Parent {
    function setNumber(uint256 newNumber) public {
        // 直接访问父合约的状态变量 number，并修改它的值
        number = newNumber;
    }
}
