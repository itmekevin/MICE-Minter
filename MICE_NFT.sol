//SPDX License Identifier: MIT

pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MICE is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    string private ipfsHash = "ipfs://QmdzoBpet8mYJpUf74vMrG5GJgByn59dcRb7b415nZy33z/Erc721_Data_"; //****** BE SURE TO UPDATE THIS
    string unrevealed = "0";

    address artist = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2; //****** BE SURE TO UPDATE THIS
    address dev = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db; //****** BE SURE TO UPDATE THIS

    uint256 public MICEcost = 250000000000000000 wei; //**** BE SURE TO UPDATE THIS
    uint256 public MICEpresaleCost = 250000000000000000 wei;
    uint256 public maxNFT = 10000;
    uint256 public txnLimit = 5;

    bool public presaleActive = false; // determines whether presale is active
    bool public whitelistSaleActive = false; // determines whether whitelistSale is active
    bool public saleActive = false; // determines whether sale is active
    bool public creditCardSaleActive = false; // determines whether creditCard is active
    bool public revealed = false;

    mapping (address => bool) public whitelist;


    constructor() ERC721("MICE NFT", "MICE") { //****** BE SURE TO UPDATE THIS
    }

// @dev allows for minting at presale price
    function presale(uint256 numTokens) external payable {
        require (presaleActive);
        require (msg.value >= MICEpresaleCost*numTokens);
        require (numTokens + _tokenIds.current() <= maxNFT);
        require (numTokens <= txnLimit);
        uint256 i = 0;
        while (i < numTokens) {
            _tokenIds.increment();
            _safeMint(msg.sender, _tokenIds.current());
            i ++;
        }
    }

// @dev allows for minting by whitelisted addresses only
    function WhiteListSale(uint256 numTokens) external payable {
        require (whitelistSaleActive);
        require (isWhitelisted(msg.sender));
        require (msg.value >= MICEcost*numTokens);
        require (numTokens + _tokenIds.current() <= maxNFT);
        require (numTokens <= txnLimit);
        uint256 i = 0;
        while (i < numTokens) {
            _tokenIds.increment();
            _safeMint(msg.sender, _tokenIds.current());
            i ++;
        }
    }

// @dev public minting round
    function sale(uint256 numTokens) external payable {
        require (saleActive);
        require (msg.value >= MICEcost*numTokens);
        require (numTokens + _tokenIds.current() <= maxNFT);
        require (numTokens <= txnLimit);
        uint256 i = 0;
        while (i < numTokens) {
            _tokenIds.increment();
            _safeMint(msg.sender, _tokenIds.current());
            i ++;
        }
    }

// @dev owner can mint NFTs to multiple addresses in single txn by inputting a list of addresses as an array
    function creditCardSale(address[] memory minter) external onlyOwner{
        require (creditCardSaleActive);
        require (minter.length + _tokenIds.current() <= maxNFT);
        for (uint256 i = 0; i < minter.length; i++) {
            _tokenIds.increment();
            _safeMint(minter[i], _tokenIds.current());
        }
    }
    
 // @dev allows for minting by the team for marketing purposes
    function marketingMint(uint256 numTokens) external onlyOwner {
        require (numTokens + _tokenIds.current() <= maxNFT);
        uint256 i = 0;
        while (i < numTokens) {
            _tokenIds.increment();
            _safeMint(msg.sender, _tokenIds.current());
            i ++;
        }
    }

    // @dev flips the state for presale
    function flipPresale() public onlyOwner {
        presaleActive = !presaleActive;
    }

    // @dev flips the state for whitelistSale
    function flipSaleState() public onlyOwner {
        saleActive = !saleActive;
    }

    // @dev flips the state for publicSale
    function flipWhitelistSaleState() public onlyOwner {
        whitelistSaleActive = !whitelistSaleActive;
    }

    // @dev flips the state for creditCardSale
    function flipCreditCardSale() public onlyOwner {
        creditCardSaleActive = !creditCardSaleActive;
    }

    // @dev add user to whitelist
    function addToWhitelist(address[] memory addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelist[addrs[i]] = true;
        }
    }

    function isWhitelisted(address addr) public view returns (bool) {
        return whitelist[addr];
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return ipfsHash;
    }

    // @dev reveals all NFTs, cannot be undone
    function revealer() external onlyOwner {
      revealed = true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    _requireMinted(tokenId);
    string memory baseURI = _baseURI();
    string memory metadataPointerId = !revealed ? unrevealed : Strings.toString(tokenId);
    string memory result = string.concat(baseURI, metadataPointerId, ".json");
    return result;
    }

    // @dev changes pricing accordingly
    function changeMICEcost(uint256 _cost) external onlyOwner {
        MICEcost = _cost;
    }

    function changeMICEpresaleCost(uint256 _presaleCost) external onlyOwner {
        MICEpresaleCost = _presaleCost;
    }

    function changeTXNlimit(uint256 _txnLimit) external onlyOwner {
        txnLimit = _txnLimit;
    }

    function withdraw() external onlyOwner {
        uint256 balanceOwner = (address(this).balance / 1000) * 925; // ****UPDATE THIS TO TEAM WALLET
        uint256 balanceArtist = (address(this).balance / 1000) * 50;
        uint256 balanceDev = (address(this).balance / 1000 * 25);
        payable(msg.sender).transfer(balanceOwner);
        payable(artist).transfer(balanceArtist);
        payable(dev).transfer(balanceDev);
    }

}


