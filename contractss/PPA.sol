//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


contract PPAC is ERC721, ERC721Enumerable, ERC721URIStorage  {
    using Counters for Counters.Counter;
    Counters.Counter  private _PPAIds;
    mapping (uint => PPA) PPAs
    address contractAddress;

     struct PPA {
        string  Consumer;
        string  EP;
        uint Amount;
        uint CapFee;
    }

    constructor(address marketplaceAddress) ERC721("Power Purchase Certificate" , "PPC") {
        contractAddress = marketplaceAddress;   
    }

    function createPPA(
        string calldata _Consumer,
        string calldata _EP,
        uint _Amount,
        uint _CapFee
        ) public returns (uint) {
        _PPAIds.increment();
        uint256 newItemId = _PPAIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId , tokenURI);
        _setApprovalForAll(contractAddress, contractAddress, true);
        return newItemId;

        PPAs[newItemId] = PPA(
            _Consumer,
            _EP,
            _Amount,
           _CapFee 
        )
    }

     // The following functions are overrides required by Solidity.
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