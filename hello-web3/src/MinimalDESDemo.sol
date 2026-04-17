// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// DES 可以拆成三条主线：

// 业务流：用户向 Vault 存入抵押资产，并据此借出稳定币
// 风险流：系统依赖 Oracle 定价计算 health factor，低于阈值时触发 liquidation
// 权限流：协议通过 Multisig、Timelock 和 UUPS/Proxy 控制参数修改、合约升级和治理执行
contract MinimalDESDemo {
    mapping(address => uint256) public collateral; // 抵押，记录每个人存了多少ETH
    mapping(address => uint256) public debt; // 债务 记录每个人借了多少DES

    uint256 public ethPrice = 2000; // ETH 价格 1eth=2000$
    uint256 public constant LIQUIDATION_THRESHOLD = 75;
    uint256 public constant LIQUIDATION_PRECISION = 100; // 精准度

    event DepositCollateral(address indexed user, uint256 amount);
    event Mint(address indexed user, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed user);

    function depositCollateral() external payable {
        require(msg.value > 0, "zero collateral");
        collateral[msg.sender] += msg.value;

        emit DepositCollateral(msg.sender, msg.value);
    }

    function mint(uint256 amount) external {
        require(amount > 0, "zero amount");

        debt[msg.sender] += amount;
        // 超过一定程度就不接款？
        // 如果不达到条件，那么就会回滚，连着前面的 debt += amount 的操作一起回滚。
        require(healthFactor(msg.sender) >= 1e18, "health factor too low");

        emit Mint(msg.sender, amount);
    }

    function healthFactor(address user) public view returns (uint256) {
        if (debt[user] == 0) {
            // 这是什么意思？给出注释. 2^256 - 1 这是能装下的最大值。
            // 用最大值表示“没有债务的仓位非常安全”，同时避免 health factor 计算时除以 0。
            return type(uint256).max;
        }

        uint256 collateralValue = collateralValueInUsd(user);
        uint256 adjustedCollateral = (collateralValue * LIQUIDATION_THRESHOLD) /
            LIQUIDATION_PRECISION;

        return (adjustedCollateral * 1e18) / debt[user];
    }

    function liquidate(address user) external {
        require(healthFactor(user) < 1e18, "position is healthy");

        uint256 seizedCollateral = collateral[user];

        collateral[user] = 0;
        debt[user] = 0;

        // todo 后面改成 call
        payable(msg.sender).transfer(seizedCollateral);

        emit Liquidate(msg.sender, user);
    }

    function collateralValueInUsd(address user) public view returns (uint256) {
        return (collateral[user] * ethPrice) / 1e18;
    }

    function setEthPrice(uint256 newPrice) external {
        require(newPrice > 0, "zero price");
        ethPrice = newPrice;
    }
}
