# RightsManagerContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/RightsManagerContract.sol)

**Inherits:**
ReentrancyGuard

*Manages the transfer and approval of rights associated with NFT books.*


## State Variables
### adminContract
Reference to the admin contract for role management.


```solidity
DEF_ADMIN_contract public immutable adminContract;
```


### nftBookContract
Reference to the NFTBook contract for book ownership verification.


```solidity
NFTBookContract public immutable nftBookContract;
```


### marketplace
Reference to the marketplace contract.


```solidity
MarketplaceContract public marketplace;
```


### rightsRequests
Mapping of token ID to rights requests.


```solidity
mapping(uint256 => RightsRequestLib.RightsRequest) public rightsRequests;
```


### rightsInfo
Mapping of token ID to rights information.


```solidity
mapping(uint256 => RightsInfo) public rightsInfo;
```


## Functions
### onlyPlatformAdmin

Ensures that only platform admins can call a function.


```solidity
modifier onlyPlatformAdmin();
```

### onlyAuthor

Ensures that only the author of a specific token can call a function.


```solidity
modifier onlyAuthor(uint256 tokenId);
```

### constructor

Initializes the contract with references to the admin and NFTBook contracts.


```solidity
constructor(address _adminContract, address _nftBookContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_adminContract`|`address`|Address of the admin contract.|
|`_nftBookContract`|`address`|Address of the NFTBook contract.|


### setMarketplace

Sets the marketplace contract address.


```solidity
function setMarketplace(address newMarketplace) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newMarketplace`|`address`|Address of the new marketplace contract.|


### initiateRequest

Initiates a rights transfer request.


```solidity
function initiateRequest(uint256 tokenId, uint256 requestDate, address buyer) public onlyPlatformAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|
|`requestDate`|`uint256`|Date of the request initiation.|
|`buyer`|`address`|Address of the buyer requesting rights.|


### authorApprove

Allows an author to approve a rights request.


```solidity
function authorApprove(uint256 tokenId) external onlyAuthor(tokenId);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|


### completeTransfer

Completes the transfer of rights.


```solidity
function completeTransfer(uint256 tokenId, uint256 expirationDate, string calldata ipfsHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|
|`expirationDate`|`uint256`|Expiration date of the transferred rights.|
|`ipfsHash`|`string`|IPFS hash of the rights agreement.|


### getRightsInfo

Retrieves rights information for a specific NFT book.


```solidity
function getRightsInfo(uint256 tokenId) external view returns (RightsInfo memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the NFT book.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`RightsInfo`|Rights information associated with the book.|


## Events
### RequestInitiated
Emitted when a rights request is initiated.


```solidity
event RequestInitiated(address indexed admin, uint256 indexed tokenId, uint256 requestDate);
```

### AuthorApprovalGranted
Emitted when an author grants or declines approval for a rights request.


```solidity
event AuthorApprovalGranted(
    address indexed author, uint256 indexed tokenId, address indexed requester, bool approved, bool declined
);
```

### RightsTransferred
Emitted when rights are transferred.


```solidity
event RightsTransferred(uint256 indexed tokenId, address indexed from, address indexed to);
```

### RightsRequestDeclined
Emitted when a rights request is declined.


```solidity
event RightsRequestDeclined(uint256 indexed tokenId, address indexed initiator);
```

### RightsUpdated
Emitted when rights information is updated.


```solidity
event RightsUpdated(uint256 indexed tokenId, address indexed holder, uint256 expirationDate, string ipfsHash);
```

### MarketplaceUpdated
Emitted when the marketplace contract is updated.


```solidity
event MarketplaceUpdated(address indexed newMarketplace);
```

### AuthorSignatureReceived
Emitted when an author's signature is received.


```solidity
event AuthorSignatureReceived(address indexed author, uint256 indexed tokenId);
```

## Structs
### RightsInfo
Struct containing rights information.


```solidity
struct RightsInfo {
    address holder;
    uint256 expirationDate;
    string ipfsHash;
}
```

