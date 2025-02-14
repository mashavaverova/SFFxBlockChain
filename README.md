# 📚 NFT Book Marketplace with Rights Management

**project is under development, so you cant find any test files or autorisation implemented**

## **Project Overview**

This project is a **decentralized NFT-based marketplace** where authors can publish books as NFTs, buyers can purchase them, and administrators can manage access, payments, and rights transfers. The marketplace supports **role-based access control**, ensuring that **only authorized users** can perform specific actions.

### **Key Features**
- **NFT-based Book Publishing** – Authors can publish books as NFTs.
- **Marketplace Listings** – Authors can list and sell books.
- **Secure Payment Distribution** – Payments are split between multiple recipients.
- **Role-Based Access Control** – Admins manage platform operations.
- **Rights Management System** – Buyers can acquire rights over NFT books.

## **🛠️ Smart Contract Architecture**

The system consists of multiple smart contracts working together:

| Contract | Function |
|----------|----------|
| `NFTBookContract` | Manages book minting, publishing, and deletion of NFT books. |
| `MarketplaceContract` | Handles listing, updating, and purchasing of NFT books. |
| `RightsManagerContract` | Manages ownership rights transfers and approvals. |
| `PaymentSplitterContract` | Splits and distributes payments among multiple recipients. |
| `FundManagerContract` | Handles platform fund withdrawals and transfers. |
| `DEF_ADMIN_contract` | Implements role-based access control for administrators, fund managers, and authors. |

---

# **🔄 Workflow Overview**

### **📖 Author's Workflow** (Creating & Managing NFT Books)

1. **Request to Publish a Book**
   - Submits a **publishing request** to `NFTBookContract`.
   - Provides **title**, **IPFS hash**, and **recipient address**.

2. **Admin Approval & NFT Minting**
   - A **platform admin** must review and approve the request.
   - Upon approval, the NFT book is **minted**.

3. **Listing the Book on the Marketplace**
   - The author **lists the book** on `MarketplaceContract`.
   - Sets a **price in wei**.

4. **Updating or Removing Listings**
   - Can **update the price**.
   - Can **remove** the listing if needed.

5. **Request Deletion (Before Purchase)**
   - If the book is **not purchased**, the author can **request deletion**.
   - An **admin must approve** the deletion.
   - Once approved, the NFT is **burned**.

---

### **🛠️ Admin's Workflow** (Managing Authors, Marketplace & Funds)

1. **Managing User Roles**
   - The **default admin** assigns `PLATFORM_ADMIN_ROLE`, `FUND_MANAGER_ROLE`, and `AUTHOR_ROLE`.
   - **Platform Admins** can grant or revoke **Author roles**.

2. **Approving Book Publishing Requests**
   - Reviews and **approves** books submitted by authors.
   - NFT book is **minted** on approval.

3. **Approving/Declining Deletion Requests**
   - Admin **approves** or **declines** an author’s request to delete a book.
   - If approved, **NFT is burned** and removed from the system.

4. **Managing Funds & Withdrawals**
   - **Fund managers** handle **fund requests** via `FundManagerContract`.
   - Admins approve **fund withdrawals** and **fund transfers**.

5. **Updating Marketplace Contracts**
   - Admins can **set or update** the Rights Manager Contract.

---

### **💰 Buyer's Workflow** (Purchasing & Receiving Rights)

1. **Browsing Listings**
   - Views books listed on `MarketplaceContract`.

2. **Purchasing a Book NFT**
   - Sends **ETH** to purchase the NFT book.
   - The contract verifies:
     - The **listing is active**.
     - The **sent amount** is correct.
   - Excess ETH is **refunded**.

3. **Receiving NFT and Rights**
   - NFT **transfers to the buyer**.
   - `RightsManagerContract` updates **ownership rights**.

4. **Requesting Rights Transfer (if applicable)**
   - The buyer may request **additional rights**.
   - The **author must approve**.
   - Rights are updated and stored **on-chain**.

---

# **🔗 Smart Contract Interactions Overview**

### **📖 Authors interact with:**
- `NFTBookContract` (Publishing books)
- `MarketplaceContract` (Listing books)

### **🛠️ Admins interact with:**
- `DEF_ADMIN_contract` (Role management)
- `NFTBookContract` (Approving books)
- `MarketplaceContract` (Managing listings)
- `FundManagerContract` (Approving withdrawals)

### **💰 Buyers interact with:**
- `MarketplaceContract` (Purchasing books)
- `RightsManagerContract` (Managing rights transfers)


---

# **📜 License**

This project is licensed under the **MIT License**.

