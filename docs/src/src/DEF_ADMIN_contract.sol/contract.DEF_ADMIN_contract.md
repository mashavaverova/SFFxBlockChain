# DEF_ADMIN_contract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/DEF_ADMIN_contract.sol)

**Inherits:**
AccessControl

This contract implements role management for platform administrators, fund managers, and authors.

*Manages role-based access control with administrative functions.*


## State Variables
### PLATFORM_ADMIN_ROLE
Role for platform administrators


```solidity
bytes32 public constant PLATFORM_ADMIN_ROLE = keccak256("PLATFORM_ADMIN_ROLE");
```


### FUND_MANAGER_ROLE
Role for fund managers


```solidity
bytes32 public constant FUND_MANAGER_ROLE = keccak256("FUND_MANAGER_ROLE");
```


### AUTHOR_ROLE
Role for authors


```solidity
bytes32 public constant AUTHOR_ROLE = keccak256("AUTHOR_ROLE");
```


### defaultAdmin
Default admin of the contract


```solidity
address public immutable defaultAdmin;
```


### platformWallet
Wallet address for platform funds


```solidity
address payable private platformWallet;
```


## Functions
### constructor

Initializes the contract with a default admin and an initial platform wallet.


```solidity
constructor(address _defaultAdmin, address payable initialPlatformWallet);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_defaultAdmin`|`address`|Address of the default administrator.|
|`initialPlatformWallet`|`address payable`|Address of the initial platform wallet.|


### validateAddress

Validates that an address is not the zero address.


```solidity
function validateAddress(address account) internal pure;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to validate.|


### grantPlatformAdmin

Grants the Platform Admin role to an account.


```solidity
function grantPlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to be granted the role.|


### revokePlatformAdmin

Revokes the Platform Admin role from an account.


```solidity
function revokePlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to have the role revoked.|


### grantFundManager

Grants the Fund Manager role to an account.


```solidity
function grantFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to be granted the role.|


### revokeFundManager

Revokes the Fund Manager role from an account.


```solidity
function revokeFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to have the role revoked.|


### grantAuthorRole

Grants the Author role to an account.


```solidity
function grantAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to be granted the role.|


### revokeAuthorRole

Revokes the Author role from an account.


```solidity
function revokeAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`account`|`address`|Address to have the role revoked.|


### hasSpecificRole

Checks if an account has a specific role.


```solidity
function hasSpecificRole(bytes32 role, address account) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|The role to check.|
|`account`|`address`|The address to check.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|True if the account has the role, otherwise false.|


### _checkRole

Overrides `_checkRole` to use custom error handling.


```solidity
function _checkRole(bytes32 role, address account) internal view virtual override;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`role`|`bytes32`|Role to check.|
|`account`|`address`|Account to check.|


### setPlatformWallet

Updates the platform wallet address.


```solidity
function setPlatformWallet(address payable newWallet) external onlyRole(DEFAULT_ADMIN_ROLE);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`newWallet`|`address payable`|New wallet address.|


### getPlatformWallet

Retrieves the platform wallet address.


```solidity
function getPlatformWallet() external view returns (address payable);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address payable`|The current platform wallet address.|


## Events
### PlatformAdminGranted
Emitted when a Platform Admin role is granted.


```solidity
event PlatformAdminGranted(address indexed account, address indexed sender);
```

### PlatformAdminRevoked
Emitted when a Platform Admin role is revoked.


```solidity
event PlatformAdminRevoked(address indexed account, address indexed sender);
```

### FundManagerGranted
Emitted when a Fund Manager role is granted.


```solidity
event FundManagerGranted(address indexed account, address indexed sender);
```

### FundManagerRevoked
Emitted when a Fund Manager role is revoked.


```solidity
event FundManagerRevoked(address indexed account, address indexed sender);
```

### AuthorGranted
Emitted when an Author role is granted.


```solidity
event AuthorGranted(address indexed account, address indexed sender);
```

### AuthorRevoked
Emitted when an Author role is revoked.


```solidity
event AuthorRevoked(address indexed account, address indexed sender);
```

### PlatformWalletUpdated
Emitted when the platform wallet address is updated.


```solidity
event PlatformWalletUpdated(address indexed admin, address newWallet);
```

## Errors
### Unauthorized
Error for unauthorized access.


```solidity
error Unauthorized(address account, bytes32 requiredRole);
```

### InvalidAddress
Error for invalid address.


```solidity
error InvalidAddress(address account);
```

