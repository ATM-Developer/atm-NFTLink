// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

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

    function _newShadow(address nft, uint256 tokenId, uint256 shadowId) internal {
        shadows[nft][tokenId] = shadowId;
        shadowDetails[shadowId] = tokenDetail(nft, tokenId, true);
    }  

    function _updataShadow(uint256 tokenId, bool status) internal{
        shadowDetails[tokenId].status = status;
    }
}

interface IERC721Metadata{
    function tokenURI(uint256 tokenId) external view returns (string memory);
}


contract Shadow is ShadowStorage, IERC721{
    //ERC721 metadata
    string public name;
    string public symbol;
    uint256 public totalsupply;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    function setShadow(string memory _name, string memory _symbol) internal {
        name = _name;
        symbol = _symbol;
    }

    function ownerOf(uint256 tokenId) public view override returns(address owner){
        return _owners[tokenId];
    }

    function balanceOf(address owner) public view override returns(uint256 balance){
        return _balances[owner];
    }

    function tokenURI(uint256 tokenId) public view returns (string memory){
        tokenDetail memory s = shadowDetails[tokenId];
        return IERC721Metadata(s.nftAddress).tokenURI(s.tokenId);
    }
    
    function _mint(address to) private returns(uint256 tokenId) {
        totalsupply++;
        tokenId = totalsupply;
    
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _revive(address to, uint256 tokenId) private {
        require(totalsupply >= tokenId,"Shadow: unexist tokenId");
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }
   
    function mint(address to, address nft, uint256 tokenId) internal {
        require(to != address(0), "Shadow: zero address");
        uint256 sid;
        if (isExistShadow(nft, tokenId)){  
            sid = getShadowId(nft, tokenId);
            _revive(to, sid);
            _updataShadow(sid, true);
        }else {
            sid = _mint(to);   
            _newShadow(nft, tokenId, sid);
        }
    }

    function burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        _updataShadow(tokenId, false);
        emit Transfer(owner, address(0), tokenId);
    }

    //---virtuel function for ERC721 
    function approve(address to, uint256 tokenId) external override{}
    function transferFrom(address from, address to, uint256 tokenId) external override{}
    function safeTransferFrom(address from, address to, uint256 tokenId) external override{}
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override{}
    function setApprovalForAll(address operator, bool approved) external override{}
    function getApproved(uint256 tokenId) external view override returns (address){}
    function isApprovedForAll(address owner, address operator) external view override returns (bool) {}
    function supportsInterface(bytes4 interfaceId) external view override returns (bool){}
}
