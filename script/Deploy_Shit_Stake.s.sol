// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { ShitStaking } from "../src/Shit_Stake.sol";
import { ShitCoin } from "../src/Shit_Coin.sol";
import "forge-std/console.sol";

contract DeployShitStaking is Script {
    ShitStaking public shitStaking;

    function setUp() public { }

    function run() public {
        address shitTokenAddress = 0xC7f2Cf4845C6db0e1a1e91ED41Bcd0FcC1b0E141;

        vm.startBroadcast();

        shitStaking = new ShitStaking(shitTokenAddress);

        console.log("ShitStaking deployed at:", address(shitStaking));

        vm.stopBroadcast();
    }
}
