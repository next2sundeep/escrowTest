// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTA is ERC721,Ownable,ReentrancyGuard{
    string public tokenURI;
    uint256 constant price = 0.01 ether;
    address public vault;
    using Counters for Counters.Counter;
    Counters.Counter private tokenCounter;

    event VaultUpdated(address newVault);

    constructor(string memory uri,address _vault) ERC721("NFT-A","NA") Ownable(){
        tokenURI = uri;
        vault = _vault;
    }
    
    /**
     * @dev Mint a number of nfts based on the input
     * @return true on success
     */
    function mintNFT() external nonReentrant payable returns (bool){
        require(msg.value >= price,"Insufficient ETH to mint" );
        tokenCounter.increment();
        _safeMint(msg.sender,tokenCounter.current());
        payable(vault).transfer(msg.value);
        return true;
    }


    /**
     * @dev Updates the vault address
     * @param _vault - the new vault address
     */
    function updateVaultAddress(address _vault) external onlyOwner() {
        require(_vault != address(0) ,"Cannot set 0 address as vault");
        vault = _vault;
        emit VaultUpdated(_vault);
    }

}