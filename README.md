## Project Description: NFT Book Marketplace with Rights Management
This project is a decentralized NFT-based marketplace where authors can publish books as NFTs, buyers can purchase them, and administrators can manage access, payments, and rights transfers. The marketplace supports role-based access control, ensuring that only authorized users can perform specific actions.

It consists of several key smart contracts that work together:

NFTBookContract – Manages the creation, approval, and deletion of NFT books.
MarketplaceContract – Allows users to list, update, and purchase NFT books.
RightsManagerContract – Handles ownership rights transfers and approvals.
PaymentSplitterContract – Distributes revenue among multiple recipients.
FundManagerContract – Manages withdrawals and transfers of platform funds.
DEF_ADMIN_contract – Implements role-based access control for admins, fund managers, and authors.
Workflow Overview
Each participant in the system has a different interaction flow. Below is a step-by-step breakdown for authors, admins, and buyers.

📖 Author's Workflow: Creating and Managing NFT Books
Request to Publish a Book:

The author submits a publishing request via NFTBookContract, providing:
title (Book title)
bookHash (IPFS hash containing the book’s content)
recipient (Who will receive the NFT)
Approval & Minting:

A platform admin reviews and approves the request.
The NFT is minted and stored in NFTBookContract.
The book's metadata (title, author, IPFS hash, timestamps) is recorded.
Listing the Book on Marketplace:

The author lists their book via MarketplaceContract, setting a price in wei.
The contract verifies:
The author owns the NFT.
The author has the correct role.
Updating or Removing Listings:

The author can update the price of the NFT book.
If they wish to remove the book, they can delete the listing.
Request to Delete a Book (Before Purchase):

If the book has not been purchased, the author can request deletion.
A platform admin must approve the deletion.
Once approved, the NFT is burned, and metadata is removed.
🛠️ Admin's Workflow: Managing Authors, Marketplace, and Funds
Granting and Revoking Roles:

The default admin grants PLATFORM_ADMIN_ROLE, FUND_MANAGER_ROLE, and AUTHOR_ROLE.
Platform Admins can grant or revoke the Author role.
Approving Book Publishing Requests:

When an author requests to publish, a platform admin must review and approve it.
Upon approval, the NFT is minted and assigned to the recipient.
Approving or Declining Deletion Requests:

If an author requests deletion, a platform admin must approve it.
If approved, the NFT is burned, and metadata is removed.
Managing Funds & Withdrawals:

Fund managers handle fund requests via FundManagerContract.
Admins approve fund withdrawals and fund transfers.
Updating Marketplace Contracts:

Admins can set or update the Rights Manager Contract address in MarketplaceContract.
💰 Buyer's Workflow: Purchasing and Receiving Rights
Browsing Listings:

The buyer views books listed on MarketplaceContract.
Purchasing a Book NFT:

The buyer sends ETH to purchase an NFT book.
MarketplaceContract verifies:
The listing is active.
The sent amount is sufficient.
Excess ETH is refunded (if applicable).
Payments are split among recipients via PaymentSplitterContract.
Receiving NFT and Rights:

After purchase, the NFT transfers to the buyer.
RightsManagerContract manages ownership rights and IPFS agreements.
Requesting Rights Transfer (if applicable):

A buyer may request additional rights transfers via RightsManagerContract.
The request is reviewed, and the author must approve.
Once approved, ownership rights are updated and stored on-chain.
🔗 Smart Contract Interactions Overview
1️⃣ Authors interact with:

NFTBookContract (Publishing books)
MarketplaceContract (Listing books)
2️⃣ Admins interact with:

DEF_ADMIN_contract (Role management)
NFTBookContract (Approving books)
MarketplaceContract (Managing listings)
FundManagerContract (Approving withdrawals)
3️⃣ Buyers interact with:

MarketplaceContract (Purchasing books)
RightsManagerContract (Managing rights transfers)
