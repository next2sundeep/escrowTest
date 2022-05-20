// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./contractA.sol";

contract Escrow is ERC721,Ownable,ReentrancyGuard{
    string public tokenURI;
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;

    mapping(address => bool) whitelistedNFT;
    mapping(uint256 => uint256) escroNFTId;
    mapping(uint256 => address) escroNFT;

    event VaultUpdated(address newVault);

    constructor(string memory uri) ERC721("escrow","EW") Ownable(){
    }
    
    /**
     * @dev Mint a number of nfts based on the input
     * @param nftContract - address of a whitelisted nft
     * @param tokenId - id of nft 
     * @return return true on success
     */
    function mintNFT(address nftContract, uint256 tokenId) external nonReentrant payable returns (bool){
        require(whitelistedNFT[nftContract] == true,"Not whitelisted" );
        require(IERC721(nftContract).ownerOf(tokenId) == msg.sender,"You do not own the token"); 
        require(IERC721(nftContract).isApprovedForAll(msg.sender,address(this)),"token is not approved to tranfer!");
        
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);
        tokenCounter.increment();
        _safeMint(msg.sender,tokenCounter.current());
        escroNFT[tokenCounter.current()] = nftContract;
        escroNFTId[tokenCounter.current()] = tokenId;
        return true;
    }

        /**
     * @dev Mint a number of nfts based on the input
     * @param tokenId - id of nft 
     * @return return true on success
     */
    function swapback(uint256 tokenId) external nonReentrant payable returns (bool){
        require(IERC721(this).ownerOf(tokenId) == msg.sender,"You do not own the token"); 
        require(IERC721(this).isApprovedForAll(msg.sender,address(this)),"token is not approved to tranfer!");
        
        IERC721(this).transferFrom(msg.sender, address(this), tokenId);
        IERC721(escroNFT[tokenId]).transferFrom(address(this), msg.sender,escroNFTId[tokenId]);
        return true;
    }


                /**
     * @dev Adds an nft to the whitelist
      * @param nftContract - address to be whitelisted
     */
    function addNFTToWhitelist(address nftContract) external onlyOwner {
            whitelistedNFT[nftContract] = true;
    }

                /**
     * @dev Removes an nft from the whitelist
      * @param nftContract - address to be blacklisted
     */
    function removeNFTFromWhitelist(address nftContract) external onlyOwner {
            whitelistedNFT[nftContract] = false;
    }

}