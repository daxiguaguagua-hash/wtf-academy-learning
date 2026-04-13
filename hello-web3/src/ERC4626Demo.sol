// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract ERC4626Demo {
    string public name = "Value Share";
    string public symbol = "vSHARE";
    uint8 public decimals = 18;

    uint256 public totalAssets;
    uint256 public totalShares;

    mapping(address => uint256) public shareBalance;

    event Deposit(address indexed user, uint256 assets, uint256 shares);
    event Redeem(address indexed user, uint256 assets, uint256 shares);

    function deposit(uint256 assets) public returns (uint256 shares) {
        require(assets > 0, "assets must be > 0");

        shares = assets;

        totalAssets += assets;
        totalShares += shares;
        shareBalance[msg.sender] += shares;

        emit Deposit(msg.sender, assets, shares);
    }

    function redeem(uint256 shares) public returns (uint256 assets) {
        require(shares > 0, "shares must be > 0");
        require(shareBalance[msg.sender] >= shares, "not enough shares");

        assets = shares;

        shareBalance[msg.sender] -= shares;
        totalShares -= shares;
        totalAssets -= assets;

        emit Redeem(msg.sender, assets, shares);
    }

    function previewDeposit(
        uint256 assets
    ) public pure returns (uint256 shares) {
        return assets;
    }

    function previewRedeem(
        uint256 shares
    ) public pure returns (uint256 assets) {
        return shares;
    }
}
