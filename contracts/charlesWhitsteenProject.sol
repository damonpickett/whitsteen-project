// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract charlesWhitsteenProject is ERC1155, Ownable {
    // constants

    uint256 public mintPrice;
    uint256 public maxSupply;
    uint256 public maxPerTokenId;
    address payable public payments;
    bool public mintEnabled;
    bool public whitelistGiveaway;

    // uris for nft metadata
    mapping(uint256 => string) private uris;

    // whitelisted addresses and how many tokens they can purchase
    mapping(address => uint) public whitelistedAddresses;

    // tokenID mapped to date whitelist option is valid
    mapping(uint256 => uint) public validUntil;

    // tokenId => total supply
    mapping(uint256 => uint256) public totalSupply;

    // tracks the number of tokenId's minted per wallet: address => (tokenId => total minted)
    mapping(address => mapping(uint256 => uint256)) public tokenIdMints;

    // constructor
    constructor(
        string memory _name,
        uint256 _maxPerTokenId,
        uint256 _maxSupply,
        address _payments
    ) payable ERC1155(_name) {
        // initialize variables
        mintPrice = 0.01 ether;
        maxSupply = _maxSupply;
        maxPerTokenId = _maxPerTokenId;
        payments = payable(_payments);
    }

    // functions

    // enables public minting
    function publicMintEnabled(bool _mintEnabled) external onlyOwner {
        mintEnabled = _mintEnabled;
    }

    // allows owner to choose an address and how many nfts that address can mint
    function updateWhitelist(address _addr, uint _amount) public onlyOwner {
        whitelistedAddresses[_addr] = _amount;
    }

    // enables presale minting
    function whitelistMintEnabled(bool _whitelistGiveaway) external onlyOwner {
        whitelistGiveaway = _whitelistGiveaway;
    }

    // returns uri of a given tokenId
    function uri(uint256 _tokenId) override public view returns (string memory) {
        return(uris[_tokenId]);
    }

    // sets the uri for each tokenID and stores in _uris mapping
    function setTokenUri(uint256 _tokenId, string memory _uri) public onlyOwner {
        uris[_tokenId] = _uri;
    }

    // sets date for whitelisted addresses to mint by
    function setValidUntil(uint256 _tokenId, uint _daysNo) public onlyOwner {
        validUntil[_tokenId] = block.timestamp + (_daysNo * 1 days);
    }

    // returns bool whether whitelisted address can still mint
    function isValid(uint256 _tokenId) public view returns (bool) {
        return block.timestamp < validUntil[_tokenId];
    }

    // public mint
    function mint(address _recipient, uint256 _tokenId, uint256 _amount) public payable {

        if(whitelistedAddresses[msg.sender] == 0) {
            require(mintEnabled, "Minting has not been enabled.");
            require(msg.value == _amount * mintPrice, "Incorrect mint value.");
        } else {
            require(whitelistGiveaway, "Whitelist giveaway has not been enabled");
            require(isValid(_tokenId) == true, "Whitelist giveaway is no longer valid.");
            whitelistedAddresses[msg.sender] -= _amount;
        }

        require(_amount >= 1, "please enter a valid number");
        require(totalSupply[_tokenId] + _amount <= maxSupply, "Sorry, you have exceeded the supply.");
        require(tokenIdMints[msg.sender][_tokenId] + _amount <= maxPerTokenId, "Sorry, you have exceeded the alotted amount per token ID.");

        totalSupply[_tokenId] += _amount;
        tokenIdMints[msg.sender][_tokenId] += _amount;
        _mint(_recipient, _tokenId, _amount, "");
        
    }

    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(payments).call{value: address(this).balance}("");
        require(success);
  }

}