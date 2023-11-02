// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract ShadowStorage {
    struct tokenDetail{
        address nftAddress; //nft address
        uint256 tokenId;    //tokenId
        bool status;        //status 
    }

    mapping (address=> mapping(uint256=>uint256)) private shadows;  //NFT => Id => shadowId
    mapping (uint256=>tokenDetail) public shadowDetails;            //shadowId => tokenDetails

    function getShadowId(address nft, uint256 tokenId) public view returns(uint256) {
        return shadows[nft][tokenId];
    }

    function isExistShadow(address nft, uint256 tokenId) public view returns(bool) {
        return shadows[nft][tokenId] != 0;
    }

    function isActiveShadow(uint256 shadowId) public view returns(bool) {
        return shadowDetails[shadowId].status;
    }

    function _newShadow(
        address nft, 
        uint256 tokenId, 
        uint256 shadowId
    ) internal  
    {
        shadows[nft][tokenId] = shadowId;
        shadowDetails[shadowId] = tokenDetail(nft, tokenId, true);
    }  

    function _updataStatus(uint256 tokenId) internal{
        shadowDetails[tokenId].status = !shadowDetails[tokenId].status;
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
        require(to != address(0), "AST: zero address");
        if (isExistShadow(nft, tokenId)){
            uint256 sid = getShadowId(nft, tokenId);
            require(!isActiveShadow(sid), "AST: shadowToken alive");
            _transfer(address(0), to, sid);
            _updataStatus(sid);
            return sid;
        }else {
            _tokenIdTracker.increment();
            uint256 newTokenId = _tokenIdTracker.current();
            _mint(to, newTokenId);
            _newShadow(nft, tokenId, newTokenId);
            return newTokenId;
        }
    }

    function burn(uint256 tokenId) public onlyOwner {
        _updataStatus(tokenId);
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
        tokenDetail memory s = shadowDetails[tokenId];
        return IERC721Metadata(s.nftAddress).tokenURI(s.tokenId);
    }
}
