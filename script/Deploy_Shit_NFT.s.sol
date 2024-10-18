// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { ShitNFT } from "../src/Shit_NFT.sol";
import { ShitCoin } from "../src/Shit_Coin.sol";
import { ShitStaking } from "../src/Shit_Stake.sol";
import "forge-std/console.sol";

contract DeployShitNFT is Script {
    ShitNFT public shitNFT;

    function setUp() public { }

    function run() public {
        address shitTokenAddress = 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141;
        address stakingContractAddress = 0x56d0CCE363737A13796e2c5cb4d35d2bBd89a256;
        uint256 shitTokenPerNFT = 100_000_000_000_000_000_000;
        string memory uriShitNFT = "https://example.com/metadata/";

        vm.startBroadcast();

        // Triển khai contract ShitNFT
        shitNFT = new ShitNFT(shitTokenAddress, shitTokenPerNFT, uriShitNFT, stakingContractAddress);

        console.log("ShitNFT deployed at:", address(shitNFT));

        vm.stopBroadcast();
    }
}
