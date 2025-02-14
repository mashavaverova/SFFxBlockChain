// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DEF_ADMIN_contract.sol";
import "./PaymentSplitterContract.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IRightsManagerContract.sol";

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
//* ╚══════════════════════════════

    /// @notice Emitted when an NFT is listed for sale.
    event Listed(address indexed seller, uint256 indexed tokenId, uint256 price);
    /// @notice Emitted when an existing listing is updated.
    event ListingUpdated(address indexed seller, uint256 indexed tokenId, uint256 newPrice);
    /// @notice Emitted when a listing is removed.
    event ListingRemoved(address indexed seller, uint256 indexed tokenId);
    /// @notice Emitted when a purchase is completed.
    event PurchaseCompleted(address indexed buyer, uint256 indexed tokenId, uint256 price);
    /// @notice Emitted when the Rights Manager contract is updated.
    event RightsManagerUpdated(address indexed rightsManagerContract);

//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝

    /**
     * @notice Initializes the Marketplace contract.
     * @param _adminContract Address of the DEF_ADMIN_contract.
     * @param _paymentSplitter Address of the PaymentSplitter contract.
     */
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

    /// @notice Ensures that only a platform admin can call the function.
    modifier onlyPlatformAdmin() {
        require(
            adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender),
            "Unauthorized"
        );
        _;
    }
    /// @notice Ensures that only the seller of a token can call the function.
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
    function setRightsManager(address _rightsManagerContract) external {
        require(address(rightsManagerContract) == address(0), "RightsManager already set");
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

        // Check token ownership through RightsManagerContract
        address nftBookContract = rightsManagerContract.nftBookContract();
        address currentHolder = IERC721(nftBookContract).ownerOf(tokenId);
        require(currentHolder == msg.sender, "You do not own this token");

        // Ensure the author has the appropriate role
        require(adminContract.hasSpecificRole(adminContract.AUTHOR_ROLE(), msg.sender), "Caller is not an author");

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
     * @dev Handles payment and ownership transfer.
     * @param tokenId ID of the NFT book being purchased.
     */
//!! REENTRANCY ISSUE HERE
    function purchaseToken(uint256 tokenId) external payable nonReentrant {
        Listing storage listing = listings[tokenId]; // Use `storage` to modify state directly
        require(listing.active, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;
        require(seller != address(0), "Invalid seller address");

        listing.active = false;

        if (msg.value > listing.price) {
            (bool refundSuccess, ) = msg.sender.call{value: msg.value - listing.price}("");
            require(refundSuccess, "Refund failed");
        }

        paymentSplitter.splitPayment{value: listing.price}(seller);

        rightsManagerContract.completeTransfer(tokenId, block.timestamp + 365 days, "");

        delete listings[tokenId];

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
