// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Nft {
    address private _owner;
    // Token name
    string public _name;
    // Token symbol
    string public _symbol;

    uint32 private seed;
    uint16 public maxSupply;

    mapping(uint16 => address) private _owners;
    mapping(address => uint16) private _balances;

    // Check nftId if it's valid
    modifier validNft(uint16 nftId) {
        require(nftId < maxSupply, "Not valid nftId!");
        _;
    }

    event Transfer(address from, address to, uint16 tokenId);

    // Constructor parameters _nftCount and _seed, max nft number and seed for different genomes
    constructor(
        string memory name,
        string memory symbol,
        uint16 _maxSupply,
        uint32 _seed
    ) {
        _name = name;
        _symbol = symbol;
        seed = _seed;
        maxSupply = _maxSupply;
        _owner = msg.sender;
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

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function transfer(address to, uint16 tokenId) public {
        require(to != address(0), "transfer to the zero address");

        if (ownerOf(tokenId) == address(0)) {
            require(_msgSender() == _owner, "caller is not the owner");
        } else {
            require(
                ownerOf(tokenId) == _msgSender(),
                "transfer from incorrect owner"
            );

            _balances[_msgSender()] -= 1;
        }

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(_msgSender(), to, tokenId);
    }

    function balanceOf(address owner) public view returns (uint16) {
        require(owner != address(0), "address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint16 tokenId) public view returns (address) {
        require(tokenId < maxSupply, "not valid tokenId");
        address owner = _owners[tokenId];
        return owner;
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
}
