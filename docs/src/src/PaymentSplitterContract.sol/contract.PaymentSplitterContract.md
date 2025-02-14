# PaymentSplitterContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/PaymentSplitterContract.sol)

**Inherits:**
ReentrancyGuard

*Handles payment distribution among multiple recipients with configurable splits and platform fees.*


## State Variables
### adminContract
Reference to the admin contract for role management.


```solidity
DEF_ADMIN_contract public immutable adminContract;
```


### PERCENTAGE_DENOMINATOR
Denominator for percentage calculations.


```solidity
uint256 private constant PERCENTAGE_DENOMINATOR = 100;
```


### authorSplits
Mapping of author addresses to their split configurations.


```solidity
mapping(address => SplitConfig) public authorSplits;
```


## Functions
### onlyPlatformAdmin

Ensures that only platform admins can call a function.


```solidity
modifier onlyPlatformAdmin();
```

### onlyAuthorOrAdmin

Ensures that only authors or platform admins can call a function.


```solidity
modifier onlyAuthorOrAdmin();
```

### constructor

Initializes the contract with the admin contract address.


```solidity
constructor(address _adminContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_adminContract`|`address`|Address of the admin contract.|


### setPlatformFee

Sets the platform fee for an author.


```solidity
function setPlatformFee(address author, uint256 fee) external onlyPlatformAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|The address of the author.|
|`fee`|`uint256`|The platform fee in percentage (max 100).|


### setAuthorSplits

Configures the payment split for an author.


```solidity
function setAuthorSplits(address author, address[] calldata recipients, uint256[] calldata percentages)
    external
    onlyAuthorOrAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author.|
|`recipients`|`address[]`|List of recipient addresses.|
|`percentages`|`uint256[]`|Corresponding percentages for each recipient.|


### deleteAuthorSplits

Deletes an author's split configuration.


```solidity
function deleteAuthorSplits(address author) external onlyAuthorOrAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author.|


### splitPayment

Splits and distributes a payment according to an author's configuration.


```solidity
function splitPayment(address author) external payable nonReentrant;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author receiving the payment.|


### getPlatformFee

Retrieves the platform fee for a specific author.


```solidity
function getPlatformFee(address author) external view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|Platform fee percentage.|


### getRecipients

Retrieves the recipients for a specific author.


```solidity
function getRecipients(address author) external view returns (address[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address[]`|List of recipient addresses.|


### getPercentages

Retrieves the split percentages for a specific author.


```solidity
function getPercentages(address author) external view returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`author`|`address`|Address of the author.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|List of split percentages.|


### claimFailedPayments

Claims failed payments and sends them to the platform admin.


```solidity
function claimFailedPayments() external onlyPlatformAdmin;
```

## Events
### PaymentSplit
Emitted when a payment is successfully split.


```solidity
event PaymentSplit(address indexed author, uint256 totalAmount);
```

### SplitConfigUpdated
Emitted when an author's split configuration is updated.


```solidity
event SplitConfigUpdated(address indexed author, address[] recipients, uint256[] percentages);
```

### SplitConfigDeleted
Emitted when an author's split configuration is deleted.


```solidity
event SplitConfigDeleted(address indexed author);
```

### PlatformFeeUpdated
Emitted when the platform fee is updated.


```solidity
event PlatformFeeUpdated(address indexed admin, uint256 platformFee);
```

### PaymentFailed
Emitted when a payment transfer fails.


```solidity
event PaymentFailed(address indexed recipient, uint256 amount);
```

## Structs
### SplitConfig
Struct representing the split configuration for an author.


```solidity
struct SplitConfig {
    address[] recipients;
    uint256[] percentages;
    uint256 platformFee;
}
```

