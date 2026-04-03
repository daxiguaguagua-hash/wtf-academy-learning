// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MappingDemo {
    /**
     * @notice 如果key的值是address，那么valude的默认值是0
     * @notice 如果key的值是boolean，那么value的默认值是false
     * 这是根据key的数据类型来决定的
     */
    mapping(address => uint256) public balances;
    /**
     * 如果要判断一个mapping值是不是被写过，需要再定义一个
     */
    mapping(address => bool) public hasBalanceRecord;

    /**
     * @notice 这里的user是地址。如果这个地址从来没有被写入过，那么将会返回默认值：0.
     */
    function setBalance(address user, uint256 amount) public {
        balances[user] = amount;
    }

    /**
     * @notice 这里的balances是链上的公开状态，不适合靠函数封装来隐藏。所有人可读
     * @notice 但是这里如果用函数封装了，那么函数的名字更具有可读性，并且可以返回其它数据等等。更加具有扩展性。
     */
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}
