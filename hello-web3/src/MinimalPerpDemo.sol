// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract MinimalPerpDemo {
    // 单个用户当前的多头仓位
    struct Position {
        address owner; // 仓位拥有者
        uint256 collateral; // 保证金，用户实际投入的 ETH
        uint256 leverage; // 杠杆倍数，第一版限制在 1-5 倍
        uint256 entryPrice; // 开仓价格
        uint256 size; // 仓位名义价值，通常等于 collateral * leverage
        bool isOpen; // 当前是否持仓中
    }

    // 管理员地址，负责手动更新价格
    address public admin;

    // 当前市场价格，第一版由管理员手动设置
    uint256 public currentPrice;

    // 一人一仓位
    mapping(address => Position) public positions;

    // 用户开仓时触发
    event PositionOpened(
        address indexed user,
        uint256 collateral,
        uint256 leverage,
        uint256 entryPrice,
        uint256 size
    );

    // 管理员更新价格时触发
    event PriceUpdated(uint256 oldPrice, uint256 newPrice);

    // 用户平仓时触发
    event PositionClosed(address indexed user, uint256 exitPrice, int256 pnl);

    constructor(uint256 initialPrice) {
        admin = msg.sender;
        currentPrice = initialPrice;
    }

    // 用户开多仓：
    // - 使用 msg.value 作为保证金
    // - leverage 表示杠杆倍数
    function openPosition(uint256 leverage) external payable {}

    // 用户平仓：
    // - 根据当前价格和开仓价结算盈亏
    function closePosition() external {}

    // 管理员手动更新价格：
    // - 第一版不用预言机
    function updatePrice(uint256 newPrice) external {}

    // 读取当前盈亏 PnL (Profit and Loss，盈亏)
    function getPnl(address user) public view returns (int256) {}

    // 读取当前收益率 ROI (Return on Investment，投资回报率)
    function getRoi(address user) public view returns (int256) {}
}
