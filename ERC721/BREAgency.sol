pragma solidity ^0.6.0;

import "./ERC721.sol";

contract BREAgency is ERC721 {
    
    // token ID
    uint256 private _propertyId = 1;
    
    // enumeration for constant values
    enum OfferStatus {
        Pending,
        Rejected,
        Accepted
    }
    
    // struct datatype for storing property details
    struct PropertyDetail {
        uint256 propertyId;
        address propertyOwner;
        string propertyNum;
        string propertyAddr;
        string propertyURI;
        uint256 propertyPrice;
        bool onSale;
    } 
    
    // struct datatype for storing property buyer details
    struct PropertyBuyer {
        address buyer;
        uint256 propertyId;
        uint256 offerPrice;
        OfferStatus offerStatus;
    }
    
    // array of struct {PropertyDetail}
    PropertyDetail[] public propertyDetails;
    
    // mapping to keep which properties are on sale
    //    propertyId
    mapping(uint256 => bool) public propertyOnSales;
    
    // mapping from property ID to struct PropertyDetail
    mapping(uint256 => PropertyBuyer[]) public propertyIdBuyerDetails; 
    
    // mapping to keep index of the buyer of propertyId 
    //    propertpropertyId    buyer      index
    mapping(uint256 => mapping(address => uint256)) public propertyIdBuyerIndexes;
    
    
    // events
    event propertyRegistered(
        uint256 index,
        uint256 propertyId
    );
    
    event propertyPriceChanged(
        uint256 propertyId,
        uint256 propertyPrice
    );
    
    event propertyListed(
        uint256 propertyId,
        bool onSale
    );
    
    event buyerListed(
        uint256 propertyId,
        address buyer
    );
    
    event buyerOffer(
        uint256 propertyId,
        address buyer,
        OfferStatus offerStatus
    );
    
    event propertySold(
        uint256 propertyId,
        address owner,
        address buyer,
        uint256 price
    );
    


    
    // calls the parant constructor
    constructor() 
        ERC721("BhattiRealEstateAgency", "BREAgency")
        public
    {
        
    }
    


    
    /**
     * @dev Lets anyone register their property 
     * mint token after successful registration
     * 
     * Requirements:
     * 
     * - `caller` should not be zero address
     * - given price should be valid
     * - property should not be on sale as per default
     * 
     * @param _propertyNumber string value of property's number 
     * @param _propertyAddress string value of property's address
     * @param _propertyURI string value of property's zameen.com URI
     * @param _propertyPrice uint256 value of property's base value price 
     * @return bool whether the function execution is successful
     */ 
    function registerProperty(string memory _propertyNumber, string memory _propertyAddress, string memory _propertyURI, uint256 _propertyPrice) 
        public 
        returns (bool) 
    {
        require(msg.sender != address(0), "BREAgency: caller query of zero address");
        require(_propertyPrice > 0, "BREAgency: Invalid price");
        
        address _propertyOwner = msg.sender;
        
        // pushing details to propertyDetails array
        propertyDetails.push(PropertyDetail({
            propertyId: _propertyId,
            propertyOwner: _propertyOwner,
            propertyNum: _propertyNumber,
            propertyAddr: _propertyAddress,
            propertyURI: _propertyURI,
            propertyPrice: _propertyPrice,
            onSale: false
        }));
        
        // mint token, See {ERC721:_mint}
        _mint(_propertyOwner, _propertyId);
        
        // See {ERC721:_setTokenURI}
        _setTokenURI(_propertyId, _propertyURI);
        
        // setting property to not be on sale (by default)
        propertyOnSales[_propertyId] = false;
        
        emit propertyRegistered((propertyDetails.length - 1), _propertyId);
        _propertyId++;
        return true;
    }
    
    /**
     * @dev Gets the property details of propertyId 
     * 
     * @param propertyId uint256 ID of the property to query of
     * 
     * @return uint256 value of the propertyId
     * @return address value of the property Owner
     * @return string value of the property's number 
     * @return string value of the property's address
     * @return string value of the property's zameen.com URI
     * @return uint256 value of the property's base value
     * @return bool whether the property is on sale or not 
     */ 
    function getPropertyDetails(uint256 propertyId) 
        public
        view
        returns (uint256, address, string memory, string memory, string memory, uint256, bool)
    {
        PropertyDetail memory myProperty = propertyDetails[propertyId - 1];
        return (
            myProperty.propertyId,
            myProperty.propertyOwner,
            myProperty.propertyNum,
            myProperty.propertyAddr,
            myProperty.propertyURI,
            myProperty.propertyPrice,
            myProperty.onSale
        );
    }    
    
    /**
     * @dev Lets the property owner change property's price
     * 
     * Requirements:
     *
     * - `propertyId` must exist
     * - `caller` should be approved, operator or the owner itself
     * - `propertyPrice` should be valid
     * 
     * @param propertyId uint256 ID of the property to query of
     * @param propertyPrice uint256 value of the price to be changed
     * @return bool whether the property is on sale
     */ 
    function changePropertyPrice(uint256 propertyId, uint256 propertyPrice)
        public
        returns (bool)
    {
        require(_exists(propertyId), "BREAgency: Invalid propertyId, not registered");
        require(_isApprovedOrOwner(msg.sender, propertyId), "BREAgency: caller doesnot own the property");
        require(propertyPrice > 0, "BREAgency: Invalid price");
        
        // updating price in struct array (state level)
        PropertyDetail storage myProperty = propertyDetails[propertyId - 1];
        myProperty.propertyPrice = propertyPrice;
        
        emit propertyPriceChanged(propertyId, propertyPrice);
        return true;
    }    
    
    /**
     * @dev Lets approved, operator or owner to list their property on sale
     * 
     * Requirements:
     * 
     * - `caller` should not zero address
     * - `propertyId` must exist
     * - `caller` should be approved, operator or owner 
     * 
     * @param propertyId uint256 ID of the property to query of
     * @return bool whether listing was successful or not
     */ 
    function listProperty(uint256 propertyId)
        public
        returns (bool)
    {
        require(msg.sender != address(0), "BREAgency: caller query of zero address");
        require(_exists(propertyId), "BREAgency: Invalid propertyId, not registered");
        require(_isApprovedOrOwner(msg.sender, propertyId), "BREAgency: caller doesnot own the property");
        
        // updating onSale in struct array (state level)
        PropertyDetail storage myProperty = propertyDetails[propertyId - 1];
        myProperty.onSale = true;
        
        // enable property sale in mapping
        propertyOnSales[propertyId] = true;
        
        emit propertyListed(propertyId, true);
        return true;
    }   
    
    /**
     * @dev Lets public to offer their price for propertyIds
     * 
     * Requirements:
     * 
     * - `caller` should not be zero address
     * - `propertyId` must exist
     * - `caller` should not be approved, operator or owner 
     * - `offerPrice` should be valid
     * - provided `propertyId` should be on sale
     * 
     * @param propertyId uint256 ID of the property to query of
     * @param offerPrice uint256 value of the price to be offered
     * @return bool whether offer was successful or not
     */ 
    function buyingRequest(uint256 propertyId, uint256 offerPrice)
        public
        returns (bool)
    {
        require(msg.sender != address(0), "BREAgency: caller query of zero address");
        require(_exists(propertyId), "BREAgency: Invalid propertyId, not registered");
        require(!_isApprovedOrOwner(msg.sender, propertyId), "BREAgency: caller cannot be approved, operator or owner itself");
        require(offerPrice > 0, "BREAgency: Invalid offer price");
        require(propertyOnSales[propertyId] == true, "BREAgency: mentioned property not on sale");
        
        // store property buyer's details locally
        PropertyBuyer memory propertyBuyer = PropertyBuyer({
            buyer: msg.sender,
            propertyId: propertyId,
            offerPrice: offerPrice,
            offerStatus: OfferStatus.Pending
        });
        
        // push the details to array
        propertyIdBuyerDetails[propertyId].push(propertyBuyer);
        
        // store index of the above propertyBuyer in mapping
        propertyIdBuyerIndexes[propertyId][msg.sender] = propertyIdBuyerDetails[propertyId].length - 1;
        
        emit buyerListed(propertyId, msg.sender);
        return true;
    }
    
    /**
     * @dev Lets approved, operator or owner to reject any buyer's offer
     * 
     * - calls internal function {_processOffer}
     * 
     * @param propertyId uint256 ID of the property to query of
     * @param index uint256 value of the index of  buyer in {propertyIdBuyerDetails}
     * @return bool whether rejection was successful or not
     */ 
    function rejectOffer(uint256 propertyId, uint256 index)
        public
        returns (bool)
    {
        // call to internal function
        _processOffer(msg.sender, propertyId, index, OfferStatus.Rejected);
        
        return true;
    }
    
    /**
     * @dev Lets approved, operator or owner to accept any buyer's offer
     * 
     * - calls internal function {_processOffer}
     * 
     * @param propertyId uint256 ID of the property to query of
     * @param index uint256 value of the index of buyer in {propertyIdBuyerDetails}
     * @return bool whether acceptance was successful or not
     */ 
    function acceptOffer(uint256 propertyId, uint256 index)
        public
        returns (bool)
    {
        // call to internal function
        _processOffer(msg.sender, propertyId, index, OfferStatus.Accepted);
        
        return true;
    }
    
    /**
     * @dev Lets accepted buyer buy the property
     * Transfers the property from owner to buyer
     * 
     * Requirements:
     * 
     * - `caller` should not zero address 
     * - `propertyId` must exist 
     * - propertyBuyer's offer should be in accepted status 
     * - `caller` must be the accepted property buyer 
     * - given `price` must be equal to the accepted offerPrice
     * 
     * @param propertyId uint256 ID of the property to query of
     * @param index uint256 value of the index of buyer in {propertyIdBuyerDetails}
     * @param price uint256 value equal to offered price
     * @return bool whether purchase was successful or not
     */ 
    function buyPropertyAgainstOffer(uint256 propertyId, uint256 index, uint256 price)
        public
        payable
        returns (bool)
    {
        require(msg.sender != address(0), "BREAgency: caller query of zero address");
        require(_exists(propertyId), "BREAgency: Invalid propertyId, not registered");
        
        address _owner = ownerOf(propertyId);
        address _buyer = msg.sender;
        
        // store details of buyer at specific index (locally)
        PropertyBuyer memory propertyBuyer = propertyIdBuyerDetails[propertyId][index];
        
        require(propertyBuyer.offerStatus == OfferStatus.Accepted, "BREAgency: this buyer's offer is not accepted");
        require(_buyer == propertyBuyer.buyer, "BREAgency: caller must be the accepted buyer");
        require(price == propertyBuyer.offerPrice, "BREAgency: Invalid offer price");
        
        // transfer the property from owner to buyer(new owner)
        _transfer(_owner, _buyer, propertyId);
        
        // update the property details in struct array (state level)
        PropertyDetail storage myProperty = propertyDetails[propertyId - 1];
        myProperty.propertyOwner = _buyer;
        myProperty.propertyPrice = price;
        myProperty.onSale = false;
        
        // setting property to not be on sale (by default)
        propertyOnSales[propertyId] = false;
        
        // clear the buyers of this sold property
        delete propertyIdBuyerDetails[propertyId][index];
        delete propertyIdBuyerIndexes[propertyId][_buyer];
        
        emit propertySold(propertyId, _owner, _buyer, price);
        return true;
    }
    
    fallback() external payable {
        
    }
    


    
    // Internal functions
    
    /**
     * @dev Internal function to accept or reject buyer's offer
     * 
     * Requirements:
     * 
     * - `caller` should not be zero address 
     * - `propertyId` should exist 
     * - param `owner` should be the owner of propertyId
     * 
     * @param owner address who owns propertyId 
     * @param propertyId uint256 ID of the property to query of
     * @param index uint256 value of the index of the propertyDetails
     * @param _offerStatus enum {Pending, Rejected, Accepted}
     */ 
    function _processOffer(address owner, uint256 propertyId, uint256 index, OfferStatus _offerStatus) internal {
        require(owner != address(0), "BREAgency: caller query of zero address");
        require(_exists(propertyId), "BREAgency: Invalid propertyId, not registered");
        require(owner == ownerOf(propertyId), "BREAgency: caller must own the property");
        
        // access propertyDetails to update the offerStatus (state level)
        PropertyBuyer storage propertyBuyer = propertyIdBuyerDetails[propertyId][index];
        
        propertyBuyer.offerStatus = _offerStatus;
        
        emit buyerOffer(propertyId, propertyBuyer.buyer, propertyBuyer.offerStatus);
    }
    
}