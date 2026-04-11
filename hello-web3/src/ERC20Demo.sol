/**
 * 这是一个标准，能够用来做代币/积分互换。
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @notice 我们带入场景。Alice/Bob/Charlie 现在有三个人。
 * @notice Alice是合约部署者，有1000代币。
 * @notice Bob没有代币，Alice会授权Bob可以使用300代币。
 * @notice Charlie有一个商店，Bob帮Alice买东西，使用300代币，Charlie收到了300代币的一部分。
 */
contract ERC20Demo {
    // 这三个数代币的基本信息，只是标签
    string public name = "WTF Token";
    string public symbol = "WTF";
    uint8 public decimals = 18;

    uint256 public totalSupply;

    // 余额，记账本，谁有多少钱
    mapping(address => uint256) public balanceOf;
    // 授权
    // allowance[owner][spender] = amount
    // 这里是 owner 授权给 spender 可以使用的 amount 数量，就是能够使用多少钱。
    // 谁的钱->授权给谁花->最多能花多少
    mapping(address => mapping(address => uint256)) public allowance;

    // 直接转账
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 先授权，再让TransferFrom转账
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // 合约刚刚部署时，给部署者发一笔初始代币
    constructor(uint256 _initialSupply) {
        _mint(msg.sender, _initialSupply);
    }

    // 转账
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(_to != address(0), "transfer to zero address"); // 不能转给全是0的地址
        require(balanceOf[msg.sender] >= _amount, "balance not enough"); // 转账的人钱够不够？

        balanceOf[msg.sender] -= _amount; // 转账的人钱减少
        balanceOf[_to] += _amount; // 收代币的人钱增加

        emit Transfer(msg.sender, _to, _amount);
        return true;
    }

    // 发授权额度
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowance[msg.sender][_spender] = _amount; // 授权给spender可以使用的额度是_amount
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    // 消费授权额度
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        require(_to != address(0), "transfer to zero address");

        // 这是Alice授权给Bob的那300代币
        uint256 allowed = allowance[_from][msg.sender];
        // _amount 是Bob想要使用的代币数量，有可能是50/100/300
        require(_amount <= allowed, "allowance not enough");
        // Alice的账户里面的钱是不是真的够 Bob扣除？
        require(balanceOf[_from] >= _amount, "balance not enough"); // 钱够

        allowance[_from][msg.sender] = allowed - _amount;
        balanceOf[_from] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    // 增发，并且记账
    // _to 表示收代币的人的钱包地址。当前构造函数里的to是部署者。
    function _mint(address _to, uint256 _amount) internal {
        // address(0)表示：全是 0 的那个特殊地址，不能给它发代币
        require(_to != address(0), "mint to zero address");

        totalSupply += _amount;
        balanceOf[_to] += _amount;

        emit Transfer(address(0), _to, _amount);
    }
}
