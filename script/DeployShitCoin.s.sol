// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/forge-std/src/Script.sol";
import "../src/ShitCoin.sol";
import "../lib/forge-std/src/console.sol";

contract DeployShitCoin is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        ShitCoin shitCoin = new ShitCoin();
        console.log("ShitCoin deployed at:", address(shitCoin));
        
        vm.stopBroadcast();
    }
}
