// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Transparent Proxy 其实就两条线：
// 管理线：ifAdmin -> admin/upgradeTo/changeAdmin
// 业务线：fallback/receive -> _fallback -> _delegate -> implementation
contract TransparentProxyDemo {
    bytes32 private constant IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);

    bytes32 private constant ADMIN_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    constructor(
        address _implementation,
        address _admin,
        bytes memory _data
    ) payable {
        require(_implementation != address(0), "implementation is zero");
        require(_admin != address(0), "admin is zero");

        _setImplemetation(_implementation);
        _setAdmin(_admin);

        // 这里相当于初始化 TransparentLogicV1 合约的状态变量 owner 和 number
        // What	如果传了初始化数据，就立刻执行一次代理初始化
        // Why	避免部署后忘记初始化，或者被别人抢先初始化
        // When	部署 Transparent Proxy 时
        // 这也是为什么很多升级代理喜欢“部署即初始化”。
        if (_data.length > 0) {
            (bool ok, bytes memory result) = _implementation.delegatecall(
                _data
            );
            require(ok, string(result));
        }
    }

    // _ 前面的代码：函数执行前先做
    // _ 本身：把原函数体塞进来
    // _ 后面的代码：函数执行后再做
    // modifier 这种写法，更加适合“入口逻辑”，而不要放“业务逻辑”。
    modifier ifAdmin() {
        require(msg.sender == _getAdmin(), "not admin");
        _;
    }

    // 这里是从右往左看，先执行 ifAdmin，如果通过，再运行admin
    function admin() external ifAdmin returns (address) {}

    function implementation() external ifAdmin returns (address) {}

    function changeAdmin(address newAdmin) external ifAdmin {}

    function upgradeTo(address newImplementation) external ifAdmin {}

    function _getImplementation() internal view returns (address impl) {}

    function _setImplementation(address newImplementation) internal {}

    // 找到 admin 的专用存储位置
    // 从那个位置读数据
    // 把它当成地址返回出去
    function _getAdmin() internal view returns (address adm) {
        // 读取 EIP-1967 的admin槽
        bytes32 slot = ADMIN_SLOT;
        assembly {
            // 表示：去slot这个位置，把它当成地址读出来，放到adm这个变量里
            // :=	assembly / Yul 里的赋值
            adm := sload(slot)
        }
    }

    function _setAdmin(address newAdmin) internal {
        bytes32 slot = ADMIN_SLOT;
        // assembly 更像是：切出 Solidity，直接写一小段EVM汇编。
        assembly {
            sstore(slot, newAdmin)
        }
    }

    function _delegate(address impl) internal virtual {}

    function _fallback() internal {}

    fallback() external payable {}

    receive() external payable {}
}
