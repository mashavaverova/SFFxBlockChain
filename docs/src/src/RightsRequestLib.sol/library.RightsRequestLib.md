# RightsRequestLib
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/RightsRequestLib.sol)

*Library defining the structure for rights transfer requests.*


## Structs
### RightsRequest
Represents a request to transfer rights of an NFT book.

*Used in `RightsManagerContract` to track approval and completion of rights transfers.*


```solidity
struct RightsRequest {
    address requester;
    uint256 tokenId;
    uint256 requestDate;
    bool authorApproved;
    bool declined;
}
```

**Properties**

|Name|Type|Description|
|----|----|-----------|
|`requester`|`address`|The address requesting the rights transfer.|
|`tokenId`|`uint256`|The ID of the NFT book associated with the request.|
|`requestDate`|`uint256`|The timestamp of when the request was initiated.|
|`authorApproved`|`bool`|Indicates whether the author has approved the request.|
|`declined`|`bool`|Indicates whether the request has been declined.|

