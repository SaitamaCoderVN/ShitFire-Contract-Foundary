// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./Shit_Coin.sol";
import "./Shit_Stake.sol";

/**
 * @title ShitNFT
 * @dev This contract implements an ERC721 token with additional features like URI storage and controlled burning.
 *      It is designed to represent Shit NFTs. Burning is only allowed through specific functions.
 */
contract ShitNFT is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _tokenId;
    ShitCoin public immutable ShitToken;
    uint256 public immutable ShitTokenPerNFT;
    string public uri;
    ShitStaking public immutable shitStaking;

    mapping(address => address[]) private _mintedBy;
    mapping(address => uint256[]) private _tokenIdOwned;

    constructor(
        address shitToken,
        uint256 shitTokenPerNFT,
        string memory uriShitNFT,
        address stakingContract
    )
        ERC721("ShitNFT", "ShitNFT")
        Ownable(msg.sender)
    {
        require(shitToken != address(0), "Invalid Shit token address");
        require(shitTokenPerNFT > 0, "Invalid Shit token amount per NFT");
        ShitToken = ShitCoin(shitToken);
        ShitTokenPerNFT = shitTokenPerNFT;
        _tokenId = 0;
        uri = uriShitNFT;
        shitStaking = ShitStaking(stakingContract);
    }

    /**
     * @dev Mints a new token with the given URI and assigns it to the specified address.
     * @param to The address to which the token will be minted.
     */
    function shootingShitNFT(address to) public {
        uint256 tokenId = _tokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        _mintedBy[to].push(msg.sender);
        _tokenIdOwned[to].push(tokenId);
    }

    /**
     * @dev Overrides the transferFrom function to prevent token transfers.
     * @param from The address from which the token is transferred.
     * @param to The address to which the token is transferred.
     * @param tokenId The ID of the token being transferred.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override(ERC721, IERC721) {
        require(from == address(0), "Err: token transfer is BLOCKED");
        super.transferFrom(from, to, tokenId);
    }

    /**
     * @dev Retrieves the URI for the specified token.
     * @param tokenId The ID of the token for which the URI will be retrieved.
     * @return string The URI for the token metadata.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Checks whether the contract supports the given interface.
     * @param interfaceId The ID of the interface.
     * @return bool True if the contract supports the given interface, false otherwise.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Retrieves all Shit NFTs owned by a specific address.
     * @param owner The address whose Shit NFTs will be retrieved.
     * @return uint256[] An array of token IDs owned by the specified address.
     */
    function getShitNFTs(address owner) public view returns (uint256) {
        require(owner != address(0), "Invalid address");
        return _mintedBy[owner].length;
    }

    /**
     * @dev Cleans up the caller's Shit NFTs based on the number of Shit NFTs they own.
     */
    function cleanShitNFT() external {
        address[] memory ownedNFTs = _mintedBy[msg.sender];
        require(ownedNFTs.length > 0, "You don't own any Shit NFTs");

        uint256 totalFeeShitTokenAmount = 0;
        address[] memory eligibleMinters = _mintedBy[msg.sender]; // Get the list of addresses that have minted into
            // the caller's wallet

        // Calculate the total amount of ShitToken needed
        totalFeeShitTokenAmount = ShitTokenPerNFT * eligibleMinters.length;
        uint256 totalFeeShitPool = totalFeeShitTokenAmount;
        uint256 totalFeeCleanShit = totalFeeShitTokenAmount + totalFeeShitPool;

        require(ShitToken.balanceOf(msg.sender) >= totalFeeCleanShit, "Err: Insufficient transfer token balance");

        ShitToken.transferFrom(msg.sender, address(this), totalFeeShitPool);
        ShitToken.approve(address(shitStaking), totalFeeShitPool);
        shitStaking.receiveTokens(totalFeeShitPool);

        // Transfer ShitToken to the addresses that have minted into the wallet
        for (uint256 i = 0; i < eligibleMinters.length; i++) {
            require(ShitToken.transferFrom(msg.sender, eligibleMinters[i], ShitTokenPerNFT), "Err: Transfer failed");
        }

        // Burn all Shit NFTs of the caller
        _burnAllShitNFTs(msg.sender);
    }

    /**
     * @dev Internal function to burn all Shit NFTs owned by the caller.
     * @param owner The address whose Shit NFTs will be burned.
     */
    function _burnAllShitNFTs(address owner) internal {
        uint256[] memory tokenIds = _tokenIdOwned[owner];

        require(tokenIds.length > 0, "You don't own any Shit NFTs");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            super._burn(tokenIds[i]);
        }

        // Clear the mapping of the wallet address
        delete _mintedBy[owner];
    }

    /**
     * @dev Prevents any external burn attempts by overriding the `burn` function from `ERC721Burnable`.
     * This function does nothing and will revert if called.
     */
    function burn(uint256 /*tokenId*/ ) public pure override(ERC721Burnable) {
        revert("Err: Direct burn not allowed");
    }
}
