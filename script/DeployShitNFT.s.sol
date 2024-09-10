// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Script.sol";
import "../src/ShitNFT.sol";
import "../lib/forge-std/src/console.sol";

contract DeployShitNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        address airdropTokenAddress = vm.envAddress("AIRDROP_TOKEN_ADDRESS");
        uint256 tokenPerNFT = vm.envUint("TOKEN_PER_NFT");
        address rewardTokenAddress = vm.envAddress("REWARD_TOKEN_ADDRESS");
        uint256 rewardPerNFT = vm.envUint("REWARD_PER_NFT");

        ShitNFT shitNFT = new ShitNFT(airdropTokenAddress, tokenPerNFT, rewardTokenAddress, rewardPerNFT);
        console.log("ShitNFT deployed at:", address(shitNFT));

        vm.stopBroadcast();
    }
}
