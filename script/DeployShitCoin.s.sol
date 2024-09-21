// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Script.sol";
import "../src/ShitCoin.sol";
import "../lib/forge-std/src/console.sol";

contract DeployShitCoin is Script {
    ShitCoin public shitCoin;
    
    function setUp() public {}

    function run() external {
        shitCoin = new ShitCoin();

        vm.startBroadcast();

        console.log("ShitCoin deployed at:", address(shitCoin));

        vm.stopBroadcast();
    }
}
