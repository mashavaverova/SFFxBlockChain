# NFTBookContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/NFTBookContract.sol)

**Inherits:**
ERC721URIStorage, ReentrancyGuard

*Manages the creation, approval, deletion, and purchase of NFT books.*


## State Variables
### adminContract
Reference to the admin contract for role management.


```solidity
DEF_ADMIN_contract public immutable adminContract;
```


### _tokenIdCounter

```solidity
uint256 private _tokenIdCounter;
```


### requestCounter

```solidity
uint256 private requestCounter;
```


### deleteRequestCounter

```solidity
uint256 private deleteRequestCounter;
```


### publishingRequests
Mapping of request ID to publishing requests.


```solidity
mapping(uint256 => PublishingRequest) public publishingRequests;
```


### deletionRequests
Mapping of request ID to deletion requests.


```solidity
mapping(uint256 => DeletionRequest) public deletionRequests;
```


### bookMetadata
Mapping of token ID to metadata.


```solidity
mapping(uint256 => Metadata) public bookMetadata;
```


### bookPurchased
Mapping of token ID to purchase status.


```solidity
mapping(uint256 => bool) public bookPurchased;
```


## Functions
### constructor

Initializes the contract with the admin contract.


```solidity
constructor(address _adminContract) ERC721("NFTBook", "BOOK");
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_adminContract`|`address`|Address of the admin contract.|


### onlyRole

Ensures that only authorized roles can call a function.


```solidity
modifier onlyRole(bytes32 role);
```

### requestPublishBook

Requests to publish a book as an NFT.


```solidity
function requestPublishBook(address recipient, string memory title, string memory bookHash)
    external
    onlyRole(adminContract.AUTHOR_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|Address receiving the NFT.|
|`title`|`string`|Title of the book.|
|`bookHash`|`string`|IPFS hash of the book content.|


### approvePublishing

Approves and publishes a requested book as an NFT.


```solidity
function approvePublishing(uint256 requestId) external onlyRole(adminContract.PLATFORM_ADMIN_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestId`|`uint256`|ID of the publishing request.|


### requestDeleteBook

Requests to delete a book NFT.


```solidity
function requestDeleteBook(uint256 tokenId) external onlyRole(adminContract.AUTHOR_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the book NFT.|


### approveDeletion

Approves and deletes a book NFT.


```solidity
function approveDeletion(uint256 requestId) external onlyRole(adminContract.PLATFORM_ADMIN_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`requestId`|`uint256`|ID of the deletion request.|


### publishForUnregistered

Publishes a book NFT for an unregistered author.

*This function is intended for platform admins to directly mint books.*


```solidity
function publishForUnregistered(address recipient, string memory title, string memory bookHash)
    external
    onlyRole(adminContract.PLATFORM_ADMIN_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|Address receiving the NFT.|
|`title`|`string`|Title of the book.|
|`bookHash`|`string`|IPFS hash of the book content.|


### deleteForUnregistered

Deletes a book NFT for an unregistered author.

*This function is intended for platform admins to remove books that do not belong to registered authors.*


```solidity
function deleteForUnregistered(uint256 tokenId) external onlyRole(adminContract.PLATFORM_ADMIN_ROLE());
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the book NFT to be deleted.|


### markAsPurchased

Marks a book as purchased.


```solidity
function markAsPurchased(uint256 tokenId) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|ID of the purchased book NFT.|


### getNextTokenId

Retrieves the next token ID to be minted.


```solidity
function getNextTokenId() external view returns (uint256);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|The next available token ID.|


### supportsInterface

Checks if the contract supports a specific interface.

*Overrides ERC721URIStorage's `supportsInterface` function.*


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage) returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface ID to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the interface is supported, otherwise false.|


## Events
### PublishingRequested
Event emitted when a publishing request is made.


```solidity
event PublishingRequested(uint256 requestId, address indexed author, string title, string bookHash);
```

### ApprovedAndPublished
Event emitted when a book is approved and published.


```solidity
event ApprovedAndPublished(uint256 requestId, address indexed admin, uint256 tokenId);
```

### DeletionRequested
Event emitted when a deletion request is made.


```solidity
event DeletionRequested(uint256 requestId, address indexed author, uint256 tokenId);
```

### ApprovedAndDeleted
Event emitted when a book is approved and deleted.


```solidity
event ApprovedAndDeleted(uint256 requestId, address indexed admin, uint256 tokenId);
```

### Purchased
Event emitted when a book is purchased.


```solidity
event Purchased(address indexed buyer, uint256 tokenId);
```

## Structs
### PublishingRequest
Struct representing a publishing request.


```solidity
struct PublishingRequest {
    address author;
    address recipient;
    string title;
    string bookHash;
    uint256 dateRequested;
}
```

### DeletionRequest
Struct representing a deletion request.


```solidity
struct DeletionRequest {
    address author;
    uint256 tokenId;
}
```

### Metadata
Struct containing metadata about a published NFT book.


```solidity
struct Metadata {
    string title;
    address author;
    string bookHash;
    uint256 dateRequested;
    uint256 datePublished;
}
```

