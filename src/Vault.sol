// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

contract Vault {
    IERC20 public immutable token;
    address public owner;
    event ReceivedToVault(address indexed from, uint256 amount);

    constructor(IERC20 _token) {
        token = _token;
        owner = msg.sender;
    }

    // Called by SafeWallet in emergency: SafeWallet transfers tokens directly to this contract
    function notifyDeposit(address from, uint256 amount) external {
        emit ReceivedToVault(from, amount);
    }

    function balance() public view returns (uint256) {
        // For tests we query token.balanceOf externally; kept for symmetry
        return 0;
    }

    // Owner-only emergency withdraw to retrieve funds from vault
    function emergencyWithdraw(address to, uint256 amount) external {
        require(msg.sender == owner, "NOT_OWNER");
        bool ok = token.transfer(to, amount);
        require(ok, "TRANSFER_FAIL");
    }
}
