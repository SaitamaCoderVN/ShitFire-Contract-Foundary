// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title ShitStaking
 * @dev This contract allows users to stake ShitTokens and earn rewards.
 *      It manages the staking process, including receiving tokens, staking, unstaking, and claiming rewards.
 */
contract ShitStaking {
    mapping(address => uint256) public staked; // Amount of tokens staked by each address
    IERC20 public immutable ShitToken; // Address of the Shit token
    uint256 public totalRewards; // Total rewards available
    uint256 public totalStaker; // Total number of stakers

    constructor(address shitToken) {
        ShitToken = IERC20(shitToken); // Initialize the Shit token address
    }

    /**
     * @dev Receive tokens from the user and update total rewards.
     * @param amount The amount of tokens received.
     */
    function receiveTokens(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        ShitToken.transferFrom(msg.sender, address(this), amount);
        totalRewards += amount;
    }

    /**
     * @dev Allows users to stake tokens.
     * @param amount The amount of tokens to stake.
     */
    function stake(uint256 amount) external {
        require(amount > 1_000_000_000_000_000_000, "amount is <= 1_000_000_000_000_000_000");
        require(ShitToken.balanceOf(msg.sender) >= amount, "balance is <= amount");
        ShitToken.transferFrom(msg.sender, address(this), amount);
        if (staked[msg.sender] > 0) {
            claim(); // If already staked, claim rewards
        }
        staked[msg.sender] += amount; // Update the staked amount

        totalStaker += amount; // Update total stakers
    }

    /**
     * @dev Get amount of tokens staked by a user.
     * @param userAddress The address of the user.
     * @return userAmount The amount of tokens staked by the user.
     */
    function getStaked(address userAddress) external view returns (uint256 userAmount) {
        return userAmount = staked[userAddress]; // Update total stakers
    }

    /**
     * @dev Allows users to unstake tokens.
     * @param amount The amount of tokens to unstake.
     */
    function unstake(uint256 amount) external {
        require(amount > 0, "amount is <= 0");
        require(staked[msg.sender] >= amount, "amount is > staked");
        claim(); // Claim rewards before unstaking

        staked[msg.sender] -= amount; // Update the staked amount
        totalStaker -= amount; // Update total stakers
        ShitToken.transfer(msg.sender, amount); // Transfer tokens back to the user
    }

    /**
     * @dev Allows users to claim rewards based on the amount staked.
     */
    function claim() public {
        require(staked[msg.sender] > 0, "staked is <= 0");

        uint256 rewards;
        if (totalRewards > totalStaker / 2) {
            rewards = (totalRewards * staked[msg.sender]) / totalStaker; // Calculate rewards
        } else {
            rewards = 0;
        }

        totalStaker -= staked[msg.sender]; // Update total stakers
        staked[msg.sender] += rewards; // Update staked amount with rewards
        totalRewards -= rewards; // Update total rewards
        totalStaker += staked[msg.sender]; // Update total stakers
    }
}
