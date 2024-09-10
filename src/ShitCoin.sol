// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ShitCoin is ERC20 {
    constructor() ERC20("SHIT", "SHIT") {
        _mint(msg.sender, 2920000000000 * (10 ** uint256(decimals())));
    }
}
