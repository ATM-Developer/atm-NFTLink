// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract ShadowStorage {
    struct tokenDetail{address nftAddress; uint256 tokenId;}
    mapping (address=> mapping(uint256=>uint256)) private shadows;
    mapping (uint256=>tokenDetail) private shadowDetails;
    mapping (uint256=>bool) private shadowStatus;

    function getTokenDetail(uint256 shadowId) public view returns(address nft, uint256 tokenId) {
        tokenDetail memory sd = shadowDetails[shadowId];
        return (sd.nftAddress, sd.tokenId);
    }

    function getShadowId(address nft, uint256 tokenId) public view returns(uint256) {
        return shadows[nft][tokenId];
    }

    function isExistShadow(address nft, uint256 tokenId) public view returns(bool) {
        return shadows[nft][tokenId] != 0;
    }

    function isActiveShadow(uint256 shadowId) public view returns(bool) {
        return shadowStatus[shadowId];
    }

    function _addShadow(
        address nft, 
        uint256 tokenId, 
        uint256 shadowId
    ) internal  
    {
        shadows[nft][tokenId] = shadowId;
        shadowDetails[shadowId] = tokenDetail(nft, tokenId);
        shadowStatus[shadowId] = true;
    }  

    function _removeShadow(uint256 shadowId) internal {
        shadowStatus[shadowId] = false;
    }

    function _restartShadow(uint256 shadowId) internal {
        shadowStatus[shadowId] = true;
    }
}


contract ShadowToken is Ownable, ERC721, ShadowStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    constructor() ERC721("ATM ShadowToken", "AST") {}

    function mint(
        address to, 
        address nft, 
        uint256 tokenId
    ) public onlyOwner returns (uint256)
    {
        require(to != address(0), "HouseToken: to is the zero address");
        if (isExistShadow(nft, tokenId)){
            uint256 sid = getShadowId(nft, tokenId);
            require(!isActiveShadow(sid), "shadowToken active");
            _mint(to, sid);
            _restartShadow(sid);
            return sid;
        }else {
            _tokenIdTracker.increment();
            uint256 newTokenId = _tokenIdTracker.current();
            _mint(to, newTokenId);
            _addShadow(nft, tokenId, newTokenId);
            return newTokenId;
        }
    }

    function burn(uint256 tokenId) public onlyOwner {
        _burn(tokenId);
    }

    function _untransfer(
        address from, 
        address to, 
        uint256 tokenId, 
        bytes memory _date
    ) internal virtual {}

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        _untransfer(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        _untransfer(from, to, tokenId, '');
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public override {
        _untransfer(from, to, tokenId,  _data); 
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory){
        _requireMinted(tokenId);
        (address nft, uint256 id) = getTokenDetail(tokenId);
        return  IERC721Metadata(nft).tokenURI(id);
    }
}
