// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Test.sol";
import "../src/ShitCoin.sol";

contract ShitCoinTest is Test {
    ShitCoin public shitCoin;
    address public owner;
    uint256 public constant INITIAL_SUPPLY = 2920000000000 * 1e18;

    function setUp() public {
        owner = address(this);
        vm.prank(owner);
        shitCoin = new ShitCoin();
    }

    function testInitialSupply() public view {
        assertEq(shitCoin.totalSupply(), INITIAL_SUPPLY);
    }

    function testOwnerBalance() public view {
        assertEq(shitCoin.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testTokenName() public view {
        assertEq(shitCoin.name(), "SHIT");
    }

    function testTokenSymbol() public view {
        assertEq(shitCoin.symbol(), "SHIT");
    }

    function testTokenDecimals() public view {
        assertEq(shitCoin.decimals(), 18);
    }

    function testTransfer() public {
        address recipient = address(0x123);
        uint256 amount = 1000 * 1e18;

        vm.prank(owner);
        bool success = shitCoin.transfer(recipient, amount);

        assertTrue(success);
        assertEq(shitCoin.balanceOf(recipient), amount);
        assertEq(shitCoin.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function testFailTransferInsufficientBalance() public {
        address recipient = address(0x123);
        uint256 amount = INITIAL_SUPPLY + 1;

        vm.prank(owner);
        shitCoin.transfer(recipient, amount);
    }

    function testApproveAndTransferFrom() public {
        address spender = address(0x456);
        address recipient = address(0x789);
        uint256 amount = 500 * 1e18;

        vm.prank(owner);
        bool approveSuccess = shitCoin.approve(spender, amount);
        assertTrue(approveSuccess);

        vm.prank(spender);
        bool transferSuccess = shitCoin.transferFrom(owner, recipient, amount);

        assertTrue(transferSuccess);
        assertEq(shitCoin.balanceOf(recipient), amount);
        assertEq(shitCoin.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(shitCoin.allowance(owner, spender), 0);
    }
}
