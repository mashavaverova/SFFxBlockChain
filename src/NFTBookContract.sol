// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DEF_ADMIN_contract.sol";

/**
 * @title NFTBookContract
 * @dev Manages the creation, approval, deletion, and purchase of NFT books.
 */
contract NFTBookContract is ERC721URIStorage, ReentrancyGuard {
    /// @notice Reference to the admin contract for role management.
    DEF_ADMIN_contract public immutable adminContract;

    uint256 private _tokenIdCounter;
    uint256 private requestCounter;
    uint256 private deleteRequestCounter;

    /// @notice Struct representing a publishing request.
    struct PublishingRequest {
        address author;
        address recipient;
        string title;
        string bookHash; // IPFS hash for book content
        uint256 dateRequested;
    }

    /// @notice Struct representing a deletion request.
    struct DeletionRequest {
        address author;
        uint256 tokenId;
    }

    /// @notice Struct containing metadata about a published NFT book.
    struct Metadata {
        string title;
        address author;
        string bookHash; // IPFS hash
        uint256 dateRequested;
        uint256 datePublished;
    }

    /// @notice Mapping of request ID to publishing requests.
    mapping(uint256 => PublishingRequest) public publishingRequests;
    /// @notice Mapping of request ID to deletion requests.
    mapping(uint256 => DeletionRequest) public deletionRequests;
    /// @notice Mapping of token ID to metadata.
    mapping(uint256 => Metadata) public bookMetadata;
    /// @notice Mapping of token ID to purchase status.
    mapping(uint256 => bool) public bookPurchased;

//* ╔══════════════════════════════╗
//* ║            EVENTS            ║
//* ╚══════════════════════════════╝
    /// @notice Event emitted when a publishing request is made.
    event PublishingRequested(uint256 requestId, address indexed author, string title, string bookHash);
    /// @notice Event emitted when a book is approved and published.
    event ApprovedAndPublished(uint256 requestId, address indexed admin, uint256 tokenId);
    /// @notice Event emitted when a deletion request is made.
    event DeletionRequested(uint256 requestId, address indexed author, uint256 tokenId);
    /// @notice Event emitted when a book is approved and deleted.
    event ApprovedAndDeleted(uint256 requestId, address indexed admin, uint256 tokenId);
    /// @notice Event emitted when a book is purchased.
    event Purchased(address indexed buyer, uint256 tokenId);

//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝
   /**
     * @notice Initializes the contract with the admin contract.
     * @param _adminContract Address of the admin contract.
     */
    constructor(address _adminContract) ERC721("NFTBook", "BOOK") {
        require(_adminContract != address(0), "Admin contract cannot be zero address");
        adminContract = DEF_ADMIN_contract(_adminContract);
    }

//* ╔══════════════════════════════╗
//* ║          MODIFIERS           ║
//* ╚══════════════════════════════╝

    /// @notice Ensures that only authorized roles can call a function.
    modifier onlyRole(bytes32 role) {
        require(adminContract.hasSpecificRole(role, msg.sender), "Unauthorized");
        _;
    }

//* ╔══════════════════════════════╗
//* ║          FUNCTIONS           ║
//* ╚══════════════════════════════╝
    /**
     * @notice Requests to publish a book as an NFT.
     * @param recipient Address receiving the NFT.
     * @param title Title of the book.
     * @param bookHash IPFS hash of the book content.
     */
    function requestPublishBook(
        address recipient,
        string memory title,
        string memory bookHash
     ) external onlyRole(adminContract.AUTHOR_ROLE()) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(bookHash).length > 0, "Book hash cannot be empty");
        require(recipient != address(0), "Recipient cannot be zero address");

        requestCounter++; 
        publishingRequests[requestCounter] = PublishingRequest({
            author: msg.sender,
            recipient: recipient,
            title: title,
            bookHash: bookHash,
            dateRequested: block.timestamp
        });

        emit PublishingRequested(requestCounter, msg.sender, title, bookHash);
    }

    /**
     * @notice Approves and publishes a requested book as an NFT.
     * @param requestId ID of the publishing request.
     */
    function approvePublishing(uint256 requestId)
        external
        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
     {
        PublishingRequest memory request = publishingRequests[requestId];
        require(request.author != address(0), "Invalid request");

        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(request.recipient, tokenId);

        bookMetadata[tokenId] = Metadata({
            title: request.title,
            author: request.author,
            bookHash: request.bookHash,
            dateRequested: request.dateRequested,
            datePublished: block.timestamp
        });

        delete publishingRequests[requestId];

        emit ApprovedAndPublished(requestId, msg.sender, tokenId);
    }

     /**
     * @notice Requests to delete a book NFT.
     * @param tokenId ID of the book NFT.
     */
    function requestDeleteBook(uint256 tokenId) external onlyRole(adminContract.AUTHOR_ROLE()) {
        require(adminContract.hasSpecificRole(adminContract.AUTHOR_ROLE(), msg.sender), "Unauthorized");
        require(!bookPurchased[tokenId], "Book has been purchased");

        deleteRequestCounter++;
        deletionRequests[deleteRequestCounter] = DeletionRequest({
            author: msg.sender,
            tokenId: tokenId
        });

        emit DeletionRequested(deleteRequestCounter, msg.sender, tokenId);
    }

    /**
     * @notice Approves and deletes a book NFT.
     * @param requestId ID of the deletion request.
     */
    function approveDeletion(uint256 requestId)
        external
        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
    {
        DeletionRequest memory request = deletionRequests[requestId];
        require(request.author != address(0), "Invalid request");

        _burn(request.tokenId);
        delete deletionRequests[requestId];
        delete bookMetadata[request.tokenId];

        emit ApprovedAndDeleted(requestId, msg.sender, request.tokenId);
    }

    /**
     * @notice Publishes a book NFT for an unregistered author.
     * @dev This function is intended for platform admins to directly mint books.
     * @param recipient Address receiving the NFT.
     * @param title Title of the book.
     * @param bookHash IPFS hash of the book content.
     */
    function publishForUnregistered(
        address recipient,
        string memory title,
        string memory bookHash
    ) external onlyRole(adminContract.PLATFORM_ADMIN_ROLE()) {
        require(bytes(title).length > 0, "Title cannot be empty");
        require(bytes(bookHash).length > 0, "Book hash cannot be empty");
        require(recipient != address(0), "Recipient cannot be zero address");

        _tokenIdCounter++;
        uint256 tokenId = _tokenIdCounter;

        _safeMint(recipient, tokenId);

        bookMetadata[tokenId] = Metadata({
            title: title,
            author: address(0),
            bookHash: bookHash,
            dateRequested: block.timestamp,
            datePublished: block.timestamp
        });

        emit ApprovedAndPublished(0, msg.sender, tokenId); // No requestId for direct publishing
    }

    /**
     * @notice Deletes a book NFT for an unregistered author.
     * @dev This function is intended for platform admins to remove books that do not belong to registered authors.
     * @param tokenId ID of the book NFT to be deleted.
     */
    function deleteForUnregistered(uint256 tokenId)
        external
        onlyRole(adminContract.PLATFORM_ADMIN_ROLE())
    {
        require(ownerOf(tokenId) != address(0), "Book does not exist");
        require(!bookPurchased[tokenId], "Cannot delete purchased book");

        _burn(tokenId);
        delete bookMetadata[tokenId];

        emit ApprovedAndDeleted(0, msg.sender, tokenId); // No requestId for direct deletion
    }

    /**
     * @notice Marks a book as purchased.
     * @param tokenId ID of the purchased book NFT.
     */
    function markAsPurchased(uint256 tokenId) external {
        require(
            msg.sender == address(adminContract) || adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender),
            "Unauthorized"
        );
        bookPurchased[tokenId] = true;

        emit Purchased(msg.sender, tokenId);
    }

    /**
     * @notice Retrieves the next token ID to be minted.
     * @return The next available token ID.
     */
    function getNextTokenId() external view returns (uint256) {
        return _tokenIdCounter + 1;
    }
    
     /**
     * @notice Checks if the contract supports a specific interface.
     * @dev Overrides ERC721URIStorage's `supportsInterface` function.
     * @param interfaceId The interface ID to check.
     * @return True if the interface is supported, otherwise false.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
