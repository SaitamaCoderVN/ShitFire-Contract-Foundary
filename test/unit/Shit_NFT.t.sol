// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Shit_NFT.sol";
import "src/Shit_Coin.sol";
import "src/Shit_Stake.sol";

contract ShitNFTTest is Test {
    ShitNFT public shitNFT;
    ShitCoin public shitCoin;
    ShitStaking public shitStaking;

    address public owner = address(0x1);
    address public minter = address(0x2);
    string public uri = "https://example.com/metadata/";
    uint256 public shitTokenPerNFT = 100e18; // 100 token per NFT

    function setUp() public {
        shitCoin = new ShitCoin();
        shitStaking = new ShitStaking(address(shitCoin));
        shitNFT = new ShitNFT(address(shitCoin), shitTokenPerNFT, uri, address(shitStaking));

        // Grant tokens to user1 and user2
        shitCoin.transfer(owner, 1000 ether);
        shitCoin.transfer(minter, 1000 ether);
    }

    function testMintNFT() public {
        vm.startPrank(minter);
        shitNFT.shootingShitNFT(minter);
        assertEq(shitNFT.getShitNFTs(minter), 1, "Minter should own 1 NFT");
        vm.stopPrank();
    }

    function testTransferBlocked() public {
        vm.startPrank(minter);
        shitNFT.shootingShitNFT(minter);
        vm.expectRevert("Err: token transfer is BLOCKED");
        shitNFT.transferFrom(minter, address(0x3), 0);
        vm.stopPrank();
    }

    function testCleanShitNFT() public {
        vm.startPrank(minter);
        shitNFT.shootingShitNFT(minter);
        shitCoin.approve(address(shitNFT), shitTokenPerNFT * 2);
        shitNFT.cleanShitNFT();
        assertEq(shitNFT.getShitNFTs(minter), 0, "Minter should own 0 NFTs after cleaning");
        vm.stopPrank();
    }

    function testBurnNotAllowed() public {
        vm.startPrank(minter);
        shitNFT.shootingShitNFT(minter);
        vm.expectRevert("Err: Direct burn not allowed");
        shitNFT.burn(0);
        vm.stopPrank();
    }

    function testGetTokenURI() public {
        vm.startPrank(minter);
        shitNFT.shootingShitNFT(minter);
        string memory tokenUri = shitNFT.tokenURI(0);
        assertEq(tokenUri, uri, "Token URI should match the set URI");
        vm.stopPrank();
    }
}
