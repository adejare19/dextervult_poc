// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockERC20 {
    string public name = "Mock";
    string public symbol = "MCK";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "INSUFFICIENT");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(balanceOf[from] >= value, "INSUFFICIENT");
        require(allowed >= value, "NOT_ALLOWED");
        allowance[from][msg.sender] = allowed - value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        return true;
    }
}
