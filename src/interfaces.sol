// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
}

interface IDroseraTrap {
    function collect() external view returns (bytes memory);
    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory);
}
