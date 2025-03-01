# Aderyn Analysis Report

This report was generated by [Aderyn](https://github.com/Cyfrin/aderyn), a static analysis tool built by [Cyfrin](https://cyfrin.io), a blockchain security company. This report is not a substitute for manual audit or security review. It should not be relied upon for any purpose other than to assist in the identification of potential security vulnerabilities.
# Table of Contents

- [Summary](#summary)
  - [Files Summary](#files-summary)
  - [Files Details](#files-details)
  - [Issue Summary](#issue-summary)
- [Low Issues](#low-issues)
  - [L-1: Centralization Risk for trusted owners](#l-1-centralization-risk-for-trusted-owners)
  - [L-2: Unsafe ERC20 Operations should not be used](#l-2-unsafe-erc20-operations-should-not-be-used)
  - [L-3: `public` functions not used internally could be marked `external`](#l-3-public-functions-not-used-internally-could-be-marked-external)
  - [L-4: Event is missing `indexed` fields](#l-4-event-is-missing-indexed-fields)
  - [L-5: Modifiers invoked only once can be shoe-horned into the function](#l-5-modifiers-invoked-only-once-can-be-shoe-horned-into-the-function)
  - [L-6: State variable could be declared immutable](#l-6-state-variable-could-be-declared-immutable)


# Summary

## Files Summary

| Key | Value |
| --- | --- |
| .sol Files | 8 |
| Total nSLOC | 609 |


## Files Details

| Filepath | nSLOC |
| --- | --- |
| src/DEF_ADMIN_contract.sol | 84 |
| src/FundManagerContract.sol | 70 |
| src/IRightsManagerContract.sol | 5 |
| src/MarketPlace_contract.sol | 86 |
| src/NFTBookContract.sol | 151 |
| src/PaymentSplitterContract.sol | 105 |
| src/RightsManagerContract.sol | 98 |
| src/RightsRequestLib.sol | 10 |
| **Total** | **609** |


## Issue Summary

| Category | No. of Issues |
| --- | --- |
| High | 0 |
| Low | 6 |


# Low Issues

## L-1: Centralization Risk for trusted owners

Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

<details><summary>14 Found Instances</summary>


- Found in src/DEF_ADMIN_contract.sol [Line: 7](src/DEF_ADMIN_contract.sol#L7)

	```solidity
	contract DEF_ADMIN_contract is AccessControl {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 61](src/DEF_ADMIN_contract.sol#L61)

	```solidity
	    function grantPlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 67](src/DEF_ADMIN_contract.sol#L67)

	```solidity
	    function revokePlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 73](src/DEF_ADMIN_contract.sol#L73)

	```solidity
	    function grantFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 79](src/DEF_ADMIN_contract.sol#L79)

	```solidity
	    function revokeFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 85](src/DEF_ADMIN_contract.sol#L85)

	```solidity
	    function grantAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 91](src/DEF_ADMIN_contract.sol#L91)

	```solidity
	    function revokeAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE) {
	```

- Found in src/DEF_ADMIN_contract.sol [Line: 108](src/DEF_ADMIN_contract.sol#L108)

	```solidity
	    function setPlatformWallet(address payable newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
	```

- Found in src/NFTBookContract.sol [Line: 62](src/NFTBookContract.sol#L62)

	```solidity
	    ) external onlyRole(adminContract.AUTHOR_ROLE()) {
	```

- Found in src/NFTBookContract.sol [Line: 81](src/NFTBookContract.sol#L81)

	```solidity
	        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
	```

- Found in src/NFTBookContract.sol [Line: 104](src/NFTBookContract.sol#L104)

	```solidity
	    function requestDeleteBook(uint256 tokenId) external onlyRole(adminContract.AUTHOR_ROLE()) {
	```

- Found in src/NFTBookContract.sol [Line: 119](src/NFTBookContract.sol#L119)

	```solidity
	        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
	```

- Found in src/NFTBookContract.sol [Line: 135](src/NFTBookContract.sol#L135)

	```solidity
	    ) external onlyRole(adminContract.PLATFORM_ADMIN_ROLE()) {
	```

- Found in src/NFTBookContract.sol [Line: 158](src/NFTBookContract.sol#L158)

	```solidity
	        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
	```

</details>



## L-2: Unsafe ERC20 Operations should not be used

ERC20 functions may not behave as expected. For example: return values are not always meaningful. It is recommended to use OpenZeppelin's SafeERC20 library.

<details><summary>2 Found Instances</summary>


- Found in src/MarketPlace_contract.sol [Line: 102](src/MarketPlace_contract.sol#L102)

	```solidity
	            payable(msg.sender).transfer(msg.value - listing.price);
	```

- Found in src/PaymentSplitterContract.sol [Line: 131](src/PaymentSplitterContract.sol#L131)

	```solidity
	        payable(msg.sender).transfer(balance);
	```

</details>



## L-3: `public` functions not used internally could be marked `external`

Instead of marking a function as `public`, consider marking it as `external` if it is not used internally.

<details><summary>2 Found Instances</summary>


- Found in src/NFTBookContract.sol [Line: 183](src/NFTBookContract.sol#L183)

	```solidity
	    function supportsInterface(bytes4 interfaceId)
	```

- Found in src/RightsManagerContract.sol [Line: 62](src/RightsManagerContract.sol#L62)

	```solidity
	 function initiateRequest(uint256 tokenId, uint256 requestDate, address buyer) public onlyPlatformAdmin{
	```

</details>



## L-4: Event is missing `indexed` fields

Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

<details><summary>20 Found Instances</summary>


- Found in src/DEF_ADMIN_contract.sol [Line: 27](src/DEF_ADMIN_contract.sol#L27)

	```solidity
	     event PlatformWalletUpdated(address indexed admin, address newWallet);
	```

- Found in src/FundManagerContract.sol [Line: 11](src/FundManagerContract.sol#L11)

	```solidity
	    event FundsAdded(address indexed sender, uint256 amount);
	```

- Found in src/FundManagerContract.sol [Line: 12](src/FundManagerContract.sol#L12)

	```solidity
	    event FundsWithdrawn(address indexed recipient, uint256 amount);
	```

- Found in src/FundManagerContract.sol [Line: 13](src/FundManagerContract.sol#L13)

	```solidity
	    event FundsSent(address indexed recipient, uint256 amount);
	```

- Found in src/FundManagerContract.sol [Line: 14](src/FundManagerContract.sol#L14)

	```solidity
	    event WithdrawalRequested(address indexed recipient, uint256 amount);
	```

- Found in src/FundManagerContract.sol [Line: 16](src/FundManagerContract.sol#L16)

	```solidity
	    event FundTransferRequested(address indexed recipient, uint256 amount);
	```

- Found in src/MarketPlace_contract.sol [Line: 25](src/MarketPlace_contract.sol#L25)

	```solidity
	    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
	```

- Found in src/MarketPlace_contract.sol [Line: 26](src/MarketPlace_contract.sol#L26)

	```solidity
	    event ListingUpdated(address indexed seller, uint256 indexed tokenId, uint256 newPrice);
	```

- Found in src/MarketPlace_contract.sol [Line: 28](src/MarketPlace_contract.sol#L28)

	```solidity
	    event PurchaseCompleted(address indexed buyer, uint256 indexed tokenId, uint256 price);
	```

- Found in src/NFTBookContract.sol [Line: 42](src/NFTBookContract.sol#L42)

	```solidity
	    event PublishingRequested(uint256 requestId, address indexed author, string title, string bookHash);
	```

- Found in src/NFTBookContract.sol [Line: 43](src/NFTBookContract.sol#L43)

	```solidity
	    event ApprovedAndPublished(uint256 requestId, address indexed admin, uint256 tokenId);
	```

- Found in src/NFTBookContract.sol [Line: 44](src/NFTBookContract.sol#L44)

	```solidity
	    event DeletionRequested(uint256 requestId, address indexed author, uint256 tokenId);
	```

- Found in src/NFTBookContract.sol [Line: 45](src/NFTBookContract.sol#L45)

	```solidity
	    event ApprovedAndDeleted(uint256 requestId, address indexed admin, uint256 tokenId);
	```

- Found in src/NFTBookContract.sol [Line: 46](src/NFTBookContract.sol#L46)

	```solidity
	    event Purchased(address indexed buyer, uint256 tokenId);
	```

- Found in src/PaymentSplitterContract.sol [Line: 24](src/PaymentSplitterContract.sol#L24)

	```solidity
	    event PaymentSplit(address indexed author, uint256 totalAmount);
	```

- Found in src/PaymentSplitterContract.sol [Line: 25](src/PaymentSplitterContract.sol#L25)

	```solidity
	    event SplitConfigUpdated(address indexed author, address[] recipients, uint256[] percentages);
	```

- Found in src/PaymentSplitterContract.sol [Line: 27](src/PaymentSplitterContract.sol#L27)

	```solidity
	    event PlatformFeeUpdated(address indexed admin, uint256 platformFee);
	```

- Found in src/PaymentSplitterContract.sol [Line: 28](src/PaymentSplitterContract.sol#L28)

	```solidity
	    event PaymentFailed(address indexed recipient, uint256 amount);
	```

- Found in src/RightsManagerContract.sol [Line: 29](src/RightsManagerContract.sol#L29)

	```solidity
	    event RequestInitiated(address indexed admin, uint256 indexed tokenId, uint256 requestDate);
	```

- Found in src/RightsManagerContract.sol [Line: 33](src/RightsManagerContract.sol#L33)

	```solidity
	    event RightsUpdated(uint256 indexed tokenId, address indexed holder, uint256 expirationDate, string ipfsHash);
	```

</details>



## L-5: Modifiers invoked only once can be shoe-horned into the function



<details><summary>1 Found Instances</summary>


- Found in src/RightsManagerContract.sol [Line: 55](src/RightsManagerContract.sol#L55)

	```solidity
	    modifier onlyAuthor(uint256 tokenId) {
	```

</details>



## L-6: State variable could be declared immutable

State variables that are should be declared immutable to save gas. Add the `immutable` attribute to state variables that are only changed in the constructor

<details><summary>8 Found Instances</summary>


- Found in src/FundManagerContract.sol [Line: 8](src/FundManagerContract.sol#L8)

	```solidity
	    DEF_ADMIN_contract public adminContract;
	```

- Found in src/MarketPlace_contract.sol [Line: 12](src/MarketPlace_contract.sol#L12)

	```solidity
	    DEF_ADMIN_contract public adminContract;
	```

- Found in src/MarketPlace_contract.sol [Line: 13](src/MarketPlace_contract.sol#L13)

	```solidity
	    IRightsManagerContract public rightsManagerContract;
	```

- Found in src/MarketPlace_contract.sol [Line: 14](src/MarketPlace_contract.sol#L14)

	```solidity
	    PaymentSplitterContract public paymentSplitter;
	```

- Found in src/NFTBookContract.sol [Line: 9](src/NFTBookContract.sol#L9)

	```solidity
	    DEF_ADMIN_contract public adminContract;
	```

- Found in src/PaymentSplitterContract.sol [Line: 12](src/PaymentSplitterContract.sol#L12)

	```solidity
	    DEF_ADMIN_contract public adminContract;
	```

- Found in src/RightsManagerContract.sol [Line: 16](src/RightsManagerContract.sol#L16)

	```solidity
	    DEF_ADMIN_contract public adminContract;
	```

- Found in src/RightsManagerContract.sol [Line: 17](src/RightsManagerContract.sol#L17)

	```solidity
	    NFTBookContract public nftBookContract;
	```

</details>



