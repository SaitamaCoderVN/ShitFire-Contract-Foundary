// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ShitCoin
 * @dev This contract implements an ERC20 token called ShitCoin.
 *      It mints a total supply of 2,920,000,000,000 tokens to the deployer's address.
 */
contract ShitCoin is ERC20 {
    constructor() ERC20("ShitCoin", "SHIT") {
        _mint(msg.sender, 2_920_000_000_000 * (10 ** uint256(decimals())));
    }
}
