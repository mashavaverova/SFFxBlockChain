# FundManagerContract
[Git Source](https://github.com/mashavaverova/SFFxBlockChain/blob/1a11961746d5aa74c4ca6848c29f0cddff0517ce/src/FundManagerContract.sol)

**Inherits:**
ReentrancyGuard

*Manages fund-related operations with role-based access control. Fund managers can request withdrawals and transfers,
while only the default admin can approve them. Includes reentrancy protection.*


## State Variables
### adminContract
Reference to the admin contract managing roles and permissions.


```solidity
DEF_ADMIN_contract public immutable adminContract;
```


### defaultAdmin
Address of the default admin extracted from the admin contract.


```solidity
address public immutable defaultAdmin;
```


### withdrawalApproved
Mapping to track whether a withdrawal has been approved for a recipient.

*The key is the recipient's address, and the value is `true` if the withdrawal is approved, otherwise `false`.*


```solidity
mapping(address => bool) public withdrawalApproved;
```


### fundTransferApproved
Mapping to track whether a fund transfer has been approved for a recipient.

*The key is the recipient's address, and the value is `true` if the transfer is approved, otherwise `false`.*


```solidity
mapping(address => bool) public fundTransferApproved;
```


## Functions
### onlyAdmin

Ensures that only the default admin can call a function.


```solidity
modifier onlyAdmin();
```

### onlyFundManager

Ensures that only a fund manager can call a function.


```solidity
modifier onlyFundManager();
```

### constructor

Initializes the contract with the admin contract address.


```solidity
constructor(address _adminContract);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_adminContract`|`address`|The address of the DEF_ADMIN_contract that manages roles.|


### requestWithdrawal

Allows a fund manager to request a withdrawal.


```solidity
function requestWithdrawal(address recipient, uint256 amount) external onlyFundManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address to receive the funds if approved.|
|`amount`|`uint256`|The amount of ETH requested for withdrawal.|


### approveWithdrawal

Allows the default admin to approve a withdrawal request.


```solidity
function approveWithdrawal(address recipient) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address whose withdrawal request is being approved.|


### requestFundTransfer

Allows a fund manager to request a fund transfer.


```solidity
function requestFundTransfer(address recipient, uint256 amount) external onlyFundManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address to receive the funds if approved.|
|`amount`|`uint256`|The amount of ETH requested for transfer.|


### approveFundTransfer

Allows the default admin to approve a fund transfer request.


```solidity
function approveFundTransfer(address recipient) external onlyAdmin;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address`|The address whose fund transfer request is being approved.|


### addFunds

Allows anyone to add funds to the contract.


```solidity
function addFunds() external payable;
```

### withdrawFunds

Allows a fund manager to withdraw funds after approval.

*Uses reentrancy guard to prevent attacks.*


```solidity
function withdrawFunds(address payable recipient, uint256 amount) external nonReentrant onlyFundManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address payable`|The address that will receive the withdrawn funds.|
|`amount`|`uint256`|The amount of ETH to withdraw.|


### sendFunds

Allows a fund manager to send funds after approval.

*Uses reentrancy guard to prevent attacks.*


```solidity
function sendFunds(address payable recipient, uint256 amount) external nonReentrant onlyFundManager;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`recipient`|`address payable`|The address that will receive the funds.|
|`amount`|`uint256`|The amount of ETH to send.|


### receive

Allows the contract to receive ETH directly.


```solidity
receive() external payable;
```

## Events
### FundsAdded
Emitted when funds are added to the contract.


```solidity
event FundsAdded(address indexed sender, uint256 amount);
```

### FundsWithdrawn
Emitted when funds are withdrawn from the contract.


```solidity
event FundsWithdrawn(address indexed recipient, uint256 amount);
```

### FundsSent
Emitted when funds are sent to a recipient.


```solidity
event FundsSent(address indexed recipient, uint256 amount);
```

### WithdrawalRequested
Emitted when a fund manager requests a withdrawal.


```solidity
event WithdrawalRequested(address indexed recipient, uint256 amount);
```

### WithdrawalApproved
Emitted when the default admin approves a withdrawal request.


```solidity
event WithdrawalApproved(address indexed recipient);
```

### FundTransferRequested
Emitted when a fund manager requests a fund transfer.


```solidity
event FundTransferRequested(address indexed recipient, uint256 amount);
```

### FundTransferApproved
Emitted when the default admin approves a fund transfer request.


```solidity
event FundTransferApproved(address indexed recipient);
```

