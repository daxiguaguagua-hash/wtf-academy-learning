// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MessageBoard {
    // 当前留言板上展示的最新留言。
    string public message;
    // 当前这条留言是谁发的。
    address public author;

    // 前端可以监听这条事件，在留言更新后自动刷新页面。
    event MessageUpdated(address indexed caller, string newMessage);

    constructor() {
        // 给页面一个明确的初始值，便于第一次读取验证。
        message = "Hello MessageBoard!";
        author = msg.sender;
    }

    function setMessage(string calldata newMessage) public {
        // 文本类输入也要做链上兜底校验，避免空留言被写入。
        require(bytes(newMessage).length > 0, "Empty message");
        message = newMessage;
        author = msg.sender;
        emit MessageUpdated(msg.sender, newMessage);
    }
}
