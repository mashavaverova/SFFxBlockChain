// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DEF_ADMIN_contract.sol";
import "./PaymentSplitterContract.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./IRightsManagerContract.sol"; // ✅ Use interface instead of importing full contract

/**
 * @title MarketplaceContract
 * @dev Handles listing, updating, and purchasing NFT books with role-based permissions.
 */
contract MarketplaceContract is ReentrancyGuard {
    /// @notice Reference to the admin contract for role management.
    DEF_ADMIN_contract public immutable adminContract;
    /// @notice Reference to the Rights Manager contract for NFT ownership verification.
    IRightsManagerContract public rightsManagerContract;
    /// @notice Reference to the Payment Splitter contract for handling payments.
    PaymentSplitterContract public immutable paymentSplitter;

    /// @notice Struct representing a listing in the marketplace.
    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 price; // in wei
        bool active;
    }

    /// @notice Mapping of tokenId to their respective listings.
    mapping(uint256 => Listing) public listings;

    //* ╔══════════════════════════════╗
    //* ║            EVENTS            ║
    //* ╚══════════════════════════════╝

    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    event ListingUpdated(address indexed seller, uint256 indexed tokenId, uint256 newPrice);
    event ListingRemoved(address indexed seller, uint256 indexed tokenId);
    event PurchaseCompleted(address indexed buyer, uint256 indexed tokenId, uint256 price);
    event RightsManagerUpdated(address indexed rightsManagerContract);

    //* ╔══════════════════════════════╗
    //* ║         CONSTRUCTOR          ║
    //* ╚══════════════════════════════╝

    constructor(
        address _adminContract,
        address _paymentSplitter
    ) {
        require(_adminContract != address(0), "Invalid admin contract address");
        require(_paymentSplitter != address(0), "Invalid PaymentSplitter contract address");

        adminContract = DEF_ADMIN_contract(_adminContract);
        paymentSplitter = PaymentSplitterContract(_paymentSplitter);
    }

    //* ╔══════════════════════════════╗
    //* ║          MODIFIERS           ║
    //* ╚══════════════════════════════╝

    modifier onlyPlatformAdmin() {
        require(
            adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender),
            "Unauthorized"
        );
        _;
    }

    modifier onlySeller(uint256 tokenId) {
        require(listings[tokenId].seller == msg.sender, "Not the seller");
        _;
    }

    //* ╔══════════════════════════════╗
    //* ║          FUNCTIONS           ║
    //* ╚══════════════════════════════╝

    /**
     * @notice Sets the Rights Manager contract.
     * @param _rightsManagerContract Address of the Rights Manager contract.
     */
    function setRightsManager(address _rightsManagerContract) external onlyPlatformAdmin {
        require(_rightsManagerContract != address(0), "Invalid RightsManager contract address");
        rightsManagerContract = IRightsManagerContract(_rightsManagerContract);
        emit RightsManagerUpdated(_rightsManagerContract);
    }

    /**
     * @notice Lists an NFT book for sale.
     * @param tokenId ID of the NFT book.
     * @param price Price of the listing in wei.
     */
    function listToken(uint256 tokenId, uint256 price) external nonReentrant {
        require(price > 0, "Price must be greater than 0");
        require(address(rightsManagerContract) != address(0), "RightsManager not set");

        // Check token ownership through RightsManagerContract
        address nftBookContract = rightsManagerContract.nftBookContract();
        address currentHolder = IERC721(nftBookContract).ownerOf(tokenId);
        require(currentHolder == msg.sender, "You do not own this token");

        // Ensure the author has the appropriate role
        require(adminContract.hasSpecificRole(adminContract.AUTHOR_ROLE(), msg.sender), "Caller is not an author");

        // ✅ Ensure marketplace is approved to transfer the NFT
        require(IERC721(nftBookContract).getApproved(tokenId) == address(this), "Marketplace not approved");

        listings[tokenId] = Listing({
            seller: msg.sender,
            tokenId: tokenId,
            price: price,
            active: true
        });

        emit Listed(msg.sender, tokenId, price);
    }

    /**
     * @notice Updates the price of an existing listing.
     * @param tokenId ID of the listed NFT book.
     * @param newPrice New price in wei.
     */
    function updateListing(uint256 tokenId, uint256 newPrice) external nonReentrant onlySeller(tokenId) {
        require(newPrice > 0, "Price must be greater than 0");

        listings[tokenId].price = newPrice;

        emit ListingUpdated(msg.sender, tokenId, newPrice);
    }

    /**
     * @notice Removes an existing listing from the marketplace.
     * @param tokenId ID of the listed NFT book.
     */
    function removeListing(uint256 tokenId) external nonReentrant onlySeller(tokenId) {
        delete listings[tokenId];

        emit ListingRemoved(msg.sender, tokenId);
    }

    /**
     * @notice Purchases a listed NFT book.
     * @param tokenId ID of the NFT book being purchased.
     */
    function purchaseToken(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;
        require(seller != address(0), "Invalid seller address");

        listing.active = false;

        // ✅ Transfer NFT to buyer before handling payment
        address nftBookContract = rightsManagerContract.nftBookContract();
        IERC721(nftBookContract).safeTransferFrom(seller, msg.sender, tokenId);

        // ✅ Process payment
        paymentSplitter.splitPayment{value: listing.price}(seller);

        // ✅ Mark as purchased in rights manager
        rightsManagerContract.completeTransfer(tokenId, block.timestamp + 365 days, "");

        // ✅ Remove listing
        delete listings[tokenId];

        // ✅ Refund excess ETH (if overpaid)
        if (msg.value > listing.price) {
            (bool refundSuccess, ) = msg.sender.call{value: msg.value - listing.price}("");
            require(refundSuccess, "Refund failed");
        }

        emit PurchaseCompleted(msg.sender, tokenId, listing.price);
    }

    /**
     * @notice Retrieves the details of a listing.
     * @param tokenId ID of the NFT book.
     * @return The listing details.
     */
    function getListing(uint256 tokenId) external view returns (Listing memory) {
        return listings[tokenId];
    }
}
