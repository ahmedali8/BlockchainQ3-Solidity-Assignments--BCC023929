pragma solidity ^0.6.0;

import "./ERC721.sol";

contract PTown is ERC721 {
    uint256 private _tokenId;
    uint256 public price = 1 ether;
    
    constructor() ERC721("P Town Token", "PTT") public {
        
    }
    
    
    /**
     * This function allows 
     */ 
    function awardPlot(address allottee, string memory tokenURI) public returns (uint256) {
       _tokenId++;
       
       // assign new _tokenId
       uint256 newPlotId = _tokenId;
       
       // new token created and token assigned to allottee
       _mint(allottee, newPlotId);
       
       // save tokenURI against new tokenID
       _setTokenURI(newPlotId, tokenURI);       
       
       return newPlotId;
    }
}