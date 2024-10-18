// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Shit_Stake.sol";
import "src/Shit_Coin.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ShitStakingTest is Test {
    ShitStaking public stakingContract;
    IERC20 public shitToken;

    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        // Deploy token contract
        shitToken = new ShitCoin();
        stakingContract = new ShitStaking(address(shitToken));

        // Grant tokens to user1 and user2
        shitToken.transfer(user1, 1000 ether);
        shitToken.transfer(user2, 1000 ether);
    }

    function testReceiveTokens() public {
        uint256 amount = 100 ether;

        // User1 sends tokens to the contract
        vm.startPrank(user1);
        shitToken.approve(address(stakingContract), amount);
        stakingContract.receiveTokens(amount);
        vm.stopPrank();

        assertEq(stakingContract.totalRewards(), amount);
    }

    function testStake() public {
        uint256 amount = 100 ether;

        // User1 sends tokens to the contract
        vm.startPrank(user1);
        uint256 amountPrevious = stakingContract.getStaked(user1);
        shitToken.approve(address(stakingContract), amount * 2);
        // stakingContract.receiveTokens(amount);
        stakingContract.stake(amount);
        uint256 amountAfter = stakingContract.getStaked(user1);
        uint256 amountStake = amountAfter - amountPrevious;
        vm.stopPrank();

        assertEq(amountStake, amount);
    }

    function testUnstake() public {
        uint256 amount = 100 ether;
        uint256 amountUnStakePrevious;
        uint256 amountUnStakeAfter;

        // User1 sends tokens to the contract and stakes
        vm.startPrank(user1);
        shitToken.approve(address(stakingContract), amount * 2);

        stakingContract.stake(amount);

        amountUnStakePrevious = stakingContract.getStaked(user1);
        vm.stopPrank();

        // User1 unstakes
        vm.startPrank(user1);
        shitToken.approve(address(stakingContract), amount * 2);

        stakingContract.unstake(amount);

        amountUnStakeAfter = stakingContract.getStaked(user1);
        vm.stopPrank();

        assertGt(amountUnStakePrevious, 0);
    }

    function testClaimRewards() public {
        uint256 amount = 100 ether;
        uint256 amountUnStakePrevious;
        uint256 amountUnStakeAfter;

        // User1 sends tokens to the contract and stakes
        vm.startPrank(user1);
        shitToken.approve(address(stakingContract), amount * 2);
        stakingContract.stake(amount);

        amountUnStakePrevious = stakingContract.getStaked(user1);
        vm.stopPrank();

        vm.startPrank(user1);
        shitToken.approve(address(stakingContract), amount * 2);

        // Simulate having rewards
        stakingContract.receiveTokens(amount);

        // User1 claims rewards
        stakingContract.claim();
        vm.stopPrank();

        amountUnStakeAfter = stakingContract.getStaked(user1);

        // Check that rewards have been updated
        assertGt(amountUnStakeAfter, amountUnStakePrevious);
    }
}
