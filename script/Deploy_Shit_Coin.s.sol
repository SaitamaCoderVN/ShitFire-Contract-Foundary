// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Script } from "forge-std/Script.sol";
import { ShitCoin } from "../src/Shit_Coin.sol";
import "forge-std/console.sol";

contract DeployShitCoin is Script {
    ShitCoin public shitCoin;

    function setUp() public { }

    function run() external {
        shitCoin = new ShitCoin();

        vm.startBroadcast();

        console.log("ShitCoin deployed at:", address(shitCoin));

        vm.stopBroadcast();
    }
}
