// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";

import "../src/MockERC20.sol";
import "../src/SafeWallet.sol";
import "../src/Vault.sol";
import "../src/MockTrapTrue.sol";
import "../src/MockTrapFalse.sol";

contract DroseraIntegrationTest is Test {
    MockERC20 token;
    SafeWallet wallet;
    Vault vault;
    address alice = address(0xA11CE);
    address owner;

    function setUp() public {
        token = new MockERC20();

        owner = address(this);
        wallet = new SafeWallet(IERC20(address(token)), owner);
        vault = new Vault(IERC20(address(token)));

        // Mint 100 tokens to the wallet
        token.mint(address(wallet), 100 ether);

        // Sanity checks
        assertEq(token.balanceOf(address(wallet)), 100 ether);
        assertEq(token.balanceOf(address(vault)), 0);
    }

    function testNormalWithdrawNotSwept() public {
        uint256 beforeBal = token.balanceOf(address(this));

        wallet.withdraw(address(this), 10 ether);

        uint256 afterBal = token.balanceOf(address(this));

        // Confirm 10 tokens were received
        assertEq(afterBal - beforeBal, 10 ether);
    }

    function testProtectAndSweepWhenTrapTrue() public {
        MockTrapTrue trapTrue = new MockTrapTrue();

        // Ensure wallet still has correct balance after previous test
        assertEq(token.balanceOf(address(wallet)), 90 ether);

        // Properly declare samples array
        bytes ;
        samples[0] = bytes("");

        // Trigger protectAndSweep
        wallet.protectAndSweep(address(trapTrue), samples, address(vault), 50 ether);

        // Check balances after sweep
        assertEq(token.balanceOf(address(vault)), 50 ether);
        assertEq(token.balanceOf(address(wallet)), 40 ether);
    }

    function testProtectAndSweepAllowedWhenTrapFalse() public {
        MockTrapFalse trapFalse = new MockTrapFalse();

        // Properly declare samples array
        bytes ;
        samples[0] = bytes("");

        // Should revert since trap returns false
        vm.expectRevert(bytes("NO_TRIGGER"));
        wallet.protectAndSweep(address(trapFalse), samples, address(vault), 10 ether);
    }
}
