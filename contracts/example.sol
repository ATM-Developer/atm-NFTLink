// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity >=0.7.0 <0.9.0;
contract AiCloneX is ERC721, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private supply;

    string public uriPrefix = "";
    string public uriSuffix = ".json";
    string public hiddenMetadataUri;

    uint256 public cost = 0 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmountPerTx = 3;
    uint256 public WLmaxLimitPerWallet = 20;
    mapping(address => uint256) public WLwalletMints;

    bool public paused = true;
    bool public revealed = false;
    bool public dynamicCost = true;
    bool public dynamicMintAmount = true;

    constructor() ERC721("Ai CloneX", "Ai-2") {
        setHiddenMetadataUri("ipfs://QmYKZ6ZopnqCE9AKiGoKoAqsPwQApfENV5tpqQQxmZi6Qf/hidden.json");
    }

    function changeMaxMintAmountPerTx(uint256 _supply) public returns (uint256 _maxMintAmountPerTx){
        if (dynamicMintAmount == false) {
            return maxMintAmountPerTx;
        }
        if(_supply <= 1000) {
            maxMintAmountPerTx = 3;
            return maxMintAmountPerTx;
        }
        if(_supply <= maxSupply) {
            maxMintAmountPerTx = 20;
            return maxMintAmountPerTx;
        }
    }

    modifier mintCompliance(uint256 _mintAmount) {

        require(_mintAmount > 0 && _mintAmount <= changeMaxMintAmountPerTx(totalSupply()), "Invalid mint amount!");
        require(supply.current() + _mintAmount <= maxSupply, "Max supply exceeded!");
        require(WLwalletMints[msg.sender] + _mintAmount <= WLmaxLimitPerWallet, "Max mint per WL wallet exceeded!" );
        WLwalletMints[msg.sender] += _mintAmount;
        _;
    }

    function totalSupply() public view returns (uint256) {
        return supply.current();
    }

    function changeCost(uint256 _supply) internal returns(uint256 _cost) {
        if(_supply <= 1000) {
            cost = 0;
            return cost;
        }
        if(_supply <= 2000) {
            cost = 1000000000000000;
            return cost;
        }
        if(_supply <= maxSupply) {
            cost = 5000000000000000;
            return cost;
        }
    }

    function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) {
        require(!paused, "The contract is paused!");
        if (dynamicCost == true){
            require(msg.value >= changeCost(totalSupply())* _mintAmount, "Insufficient funds!");
        }else {
            require(msg.value >= cost * _mintAmount, "Insufficient funds!");
        }
        _mintLoop(msg.sender, _mintAmount);
        changeCost(totalSupply());
        changeMaxMintAmountPerTx(totalSupply());
    }

    function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
        _mintLoop(_receiver, _mintAmount);
    }

    function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = 1;
        uint256 ownedTokenIndex = 0;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {
                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;
            }

            currentTokenId++;
        }

        return ownedTokenIds;
    }

    function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : "";
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }


    function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }
    function setWLmaxLimitPerWallet(uint256 _WLmaxLimitPerWallet) public onlyOwner {
        WLmaxLimitPerWallet = _WLmaxLimitPerWallet;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setDynamicMintAmount(bool _state) public onlyOwner {
        dynamicMintAmount = _state;
    }

    function setDynamicCost(bool _state) public onlyOwner {
        changeCost(totalSupply());
        dynamicCost = _state;
    }
    function withdraw() public onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function _mintLoop(address _receiver, uint256 _mintAmount) internal {
        for (uint256 i = 0; i < _mintAmount; i++) {
            supply.increment();
            _safeMint(_receiver, supply.current());
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return uriPrefix;
    }
}