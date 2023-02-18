// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Nft is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Burnable,
    Ownable
{
    uint16 public nftCount;
    uint32 private seed;

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Check nftId if it's valid
    modifier validNft(uint16 nftId) {
        require(nftId < nftCount, "Not valid nftId!");
        _;
    }

    // Check the nftId counter if has limit to mint
    modifier validMint() {
        require(_tokenIdCounter.current() < nftCount, "No limit to mint!");
        _;
    }

    // Constructor parameters _nftCount and _seed, max nft number and seed for different genomes
    constructor(uint16 _nftCount, uint32 _seed) ERC721("Phoenix", "Phx") {
        nftCount = _nftCount;
        seed = _seed;
    }

    // Struct to hold genome attributes
    struct Attributes {
        uint8 backgroundColor;
        uint8 backgroundEffect;
        uint8 wings;
        uint8 skinColor;
        uint8 skinPattern;
        uint8 body;
        uint8 mouth;
        uint8 eyes;
        uint8 hat;
        uint8 pet;
        uint8 accessory;
        uint8 border;
    }

    // View function to get genome packed value from nftId, callable inside the contract
    function calcGenom(uint16 nftId) internal view returns (uint72) {
        return uint72(bytes9(keccak256(abi.encode(seed, nftId))));
    }

    // Public view function to get genome attributes from nftId, returning struct Attributes
    function viewGenomeAttributes(uint16 nftId)
        public
        view
        validNft(nftId)
        returns (Attributes memory)
    {
        // First calculating genome packed value
        uint72 genome = calcGenom(nftId);
        // Then return attributes from calculated value
        return
            Attributes({
                backgroundColor: (uint8(genome) & 63) % 61,
                backgroundEffect: (uint8(genome >> 6) & 63) % 61,
                wings: (uint8(genome >> 12) & 15) % 11,
                skinColor: (uint8(genome >> 16) & 63) % 41,
                skinPattern: (uint8(genome >> 22) & 15) % 11,
                body: (uint8(genome >> 26) & 127) % 101,
                mouth: (uint8(genome >> 33) & 63) % 51,
                eyes: (uint8(genome >> 39) & 63) % 61,
                hat: (uint8(genome >> 45) & 127) % 101,
                pet: (uint8(genome >> 52) & 15) % 11,
                accessory: (uint8(genome >> 56) & 31) % 26,
                border: (uint8(genome >> 61) & 31) % 31
            });
    }

    // Mint function with validMint modifier to check if has limit to mint new Nft
    function safeMint(address to, string memory uri)
        public
        validMint
        onlyOwner
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    // Same as mint function, transfer function has validNft modifier to check if the nftId is valid
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override(IERC721, ERC721) validNft(uint16(tokenId)) {
        super.safeTransferFrom(from, to, tokenId, "");
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
