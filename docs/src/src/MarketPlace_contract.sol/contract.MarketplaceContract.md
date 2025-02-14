# MarketplaceContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/MarketPlace_contract.sol)

**Inherits:**
ReentrancyGuard

*Handles listing, updating, and purchasing NFT books with role-based permissions.*


## State Variables
### adminContract
Reference to the admin contract for role management.


```solidity
DEF_ADMIN_contract public immutable adminContract;
```


### rightsManagerContract
Reference to the Rights Manager contract for NFT ownership verification.


```solidity
IRightsManagerContract public rightsManagerContract;
```


### paymentSplitter
Reference to the Payment Splitter contract for handling payments.


```solidity
PaymentSplitterContract public immutable paymentSplitter;
```


### listings
Mapping of tokenId to their respective listings.


```solidity
mapping(uint256 => Listing) public listings;
```


## Functions
### constructor

Initializes the Marketplace contract.


```solidity
constructor(address _adminContract, address _paymentSplitter);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_adminContract`|`address`|Address of the DEF_ADMIN_contract.|
|`_paymentSplitter`|`address`|Address of the PaymentSplitter contract.|


### onlyPlatformAdmin

Ensures that only a platform admin can call the function.


```solidity
modifier onlyPlatformAdmin();
```

### onlySeller

Ensures that only the seller of a token can call the function.


```solidity
modifier onlySeller(uint256 tokenId);
```

### setRightsManager

Sets the Rights Manager contract.


```solidity
function setRightsManager(address _rightsManagerContract) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_rightsManagerContract`|`address`|Address of the Rights Manager contract.|


### listToken

Lists an NFT book for sale.


```solidity
function listToken(uint256 tokenId, uint256 price) external nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|
|`price`|`uint256`|Price of the listing in wei.|


### updateListing

Updates the price of an existing listing.


```solidity
function updateListing(uint256 tokenId, uint256 newPrice) external nonReentrant onlySeller(tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the listed NFT book.|
|`newPrice`|`uint256`|New price in wei.|


### removeListing

Removes an existing listing from the marketplace.


```solidity
function removeListing(uint256 tokenId) external nonReentrant onlySeller(tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the listed NFT book.|


### purchaseToken

Purchases a listed NFT book.

*Handles payment and ownership transfer.*


```solidity
function purchaseToken(uint256 tokenId) external payable nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book being purchased.|


### getListing

Retrieves the details of a listing.


```solidity
function getListing(uint256 tokenId) external view returns (Listing memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`Listing`|The listing details.|


## Events
### Listed
Emitted when an NFT is listed for sale.


```solidity
event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
```

### ListingUpdated
Emitted when an existing listing is updated.


```solidity
event ListingUpdated(address indexed seller, uint256 indexed tokenId, uint256 newPrice);
```

### ListingRemoved
Emitted when a listing is removed.


```solidity
event ListingRemoved(address indexed seller, uint256 indexed tokenId);
```

### PurchaseCompleted
Emitted when a purchase is completed.


```solidity
event PurchaseCompleted(address indexed buyer, uint256 indexed tokenId, uint256 price);
```

### RightsManagerUpdated
Emitted when the Rights Manager contract is updated.


```solidity
event RightsManagerUpdated(address indexed rightsManagerContract);
```

## Structs
### Listing
Struct representing a listing in the marketplace.


```solidity
struct Listing {
    address seller;
    uint256 tokenId;
    uint256 price;
    bool active;
}
```

