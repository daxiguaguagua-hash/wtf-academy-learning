// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ErrorsDemo {
    uint256 public number;

    // 这种写法非常的省gas
    error NotPositive(uint256 newNumber);

    function setNumber(uint256 newNumber) public {
        // 把非法输入挡在门外
        // require(newNumber > 0, "Number must be greater than 0");

        // 省gas，经济实惠
        if (newNumber == 0) {
            revert NotPositive(newNumber);
        }

        number = newNumber;
        // 检查内部结果有没有违背预期
        assert(number > 0);
    }
}
