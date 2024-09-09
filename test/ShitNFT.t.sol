// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Test.sol";
import "../src/ShitNFT.sol";
import "../src/ShitCoin.sol";

contract ShitNFTTest is Test {
    ShitNFT public shitNFT;
    ShitCoin public airdropToken;
    ShitCoin public rewardToken;
    address public owner;
    address public user1;
    address public user2;
    uint256 public constant TOKEN_PER_NFT = 100 * 1e18;
    uint256 public constant REWARD_PER_NFT = 10 * 1e18;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        airdropToken = new ShitCoin();
        rewardToken = new ShitCoin();

        shitNFT = new ShitNFT(
            address(airdropToken),
            TOKEN_PER_NFT,
            address(rewardToken),
            REWARD_PER_NFT
        );

        // Cấp token cho contract và người dùng
        rewardToken.transfer(address(shitNFT), 1000000 * 1e18);
        airdropToken.transfer(user1, 1000 * 1e18);
        airdropToken.transfer(user2, 1000 * 1e18);
    }

    function testSafeMint() public {
        vm.startPrank(user1);
        shitNFT.safeMint(user1, "ipfs://QmTest1");
        vm.stopPrank();

        assertEq(shitNFT.balanceOf(user1), 1);
        assertEq(shitNFT.ownerOf(0), user1);
        assertEq(shitNFT.tokenURI(0), "ipfs://QmTest1");
    }

    function testMultipleSafeMint() public {
        vm.startPrank(user1);
        shitNFT.safeMint(user1, "ipfs://QmTest1");
        shitNFT.safeMint(user1, "ipfs://QmTest2");
        vm.stopPrank();

        vm.prank(user2);
        shitNFT.safeMint(user2, "ipfs://QmTest3");

        assertEq(shitNFT.balanceOf(user1), 2);
        assertEq(shitNFT.balanceOf(user2), 1);
        assertEq(shitNFT.ownerOf(0), user1);
        assertEq(shitNFT.ownerOf(1), user1);
        assertEq(shitNFT.ownerOf(2), user2);
    }

    function testAirdropTokens() public {
        // Mint NFTs
        vm.startPrank(user1);
        shitNFT.safeMint(user1, "ipfs://QmTest1");
        shitNFT.safeMint(user1, "ipfs://QmTest2");
        vm.stopPrank();

        vm.prank(user2);
        shitNFT.safeMint(user2, "ipfs://QmTest3");

        // Approve airdrop tokens
        vm.prank(user1);
        airdropToken.approve(address(shitNFT), 1000 * 1e18);

        // Ghi nhận số dư ban đầu
        uint256 initialBalance = airdropToken.balanceOf(user1);
        uint256 initialRewardBalance = rewardToken.balanceOf(user1);
        uint256 initialUser2Balance = airdropToken.balanceOf(user2);

        // Thực hiện airdrop
        vm.prank(user1);
        shitNFT.airdropTokens();

        // Kiểm tra số dư sau airdrop
        assertEq(airdropToken.balanceOf(user1), initialBalance - (2 * TOKEN_PER_NFT), "User1 airdrop balance incorrect");
        assertEq(airdropToken.balanceOf(user2), initialUser2Balance + (2 * TOKEN_PER_NFT), "User2 airdrop balance incorrect");
        assertEq(rewardToken.balanceOf(user1), initialRewardBalance + (2 * REWARD_PER_NFT), "User1 reward balance incorrect");

        // Kiểm tra NFTs đã bị đốt
        assertEq(shitNFT.balanceOf(user1), 0, "User1 should have no NFTs left");
        vm.expectRevert("ERC721: invalid token ID");
        shitNFT.ownerOf(0);
    }

    function testFailAirdropInsufficientBalance() public {
        vm.prank(user1);
        shitNFT.safeMint(user1, "ipfs://QmTest1");

        vm.prank(user1);
        airdropToken.transfer(address(0), airdropToken.balanceOf(user1));

        vm.prank(user1);
        shitNFT.airdropTokens();
    }

    function testFailAirdropNoNFTs() public {
        vm.prank(user1);
        shitNFT.airdropTokens();
    }
}