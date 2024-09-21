// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Script.sol";
import "../src/ShitNFT.sol";
import "../lib/forge-std/src/console.sol";

contract DeployShitNFT is Script {

    ShitNFT public shitNFT;
    
    function setUp() public {}

    function run() external {

        vm.startBroadcast();

        address airdropTokenAddress = vm.envAddress("AIRDROP_TOKEN_ADDRESS");
        uint256 tokenPerNFT = vm.envUint("TOKEN_PER_NFT");
        address rewardTokenAddress = vm.envAddress("REWARD_TOKEN_ADDRESS");
        uint256 rewardPerNFT = vm.envUint("REWARD_PER_NFT");

        shitNFT = new ShitNFT(airdropTokenAddress, tokenPerNFT, rewardTokenAddress, rewardPerNFT);
        console.log("ShitNFT deployed at:", address(shitNFT));

        vm.stopBroadcast();
    }
}
