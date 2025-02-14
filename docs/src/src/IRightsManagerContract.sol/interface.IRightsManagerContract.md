# IRightsManagerContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/IRightsManagerContract.sol)

*Interface for managing rights transfers associated with NFT books.*


## Functions
### completeTransfer

Completes the transfer of rights for a given NFT book.

*This function should be called to finalize a rights transfer, setting an expiration date and an IPFS hash for reference.*


```solidity
function completeTransfer(uint256 tokenId, uint256 expirationDate, string calldata ipfsHash) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`tokenId`|`uint256`|The unique identifier of the NFT book whose rights are being transferred.|
|`expirationDate`|`uint256`|The timestamp (in seconds) when the transferred rights will expire.|
|`ipfsHash`|`string`|A string containing the IPFS hash of the associated metadata.|


### nftBookContract

Retrieves the address of the NFT book contract associated with this rights manager.


```solidity
function nftBookContract() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|The address of the NFT book contract.|


