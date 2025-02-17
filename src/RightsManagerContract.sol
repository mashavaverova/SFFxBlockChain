// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "./DEF_ADMIN_contract.sol";
import "./NFTBookContract.sol";
import "./MarketPlace_contract.sol";
import "forge-std/console.sol";
import "./RightsRequestLib.sol";


/**
 * @title RightsManagerContract
 * @dev Manages the transfer and approval of rights associated with NFT books.
 */
contract RightsManagerContract is ReentrancyGuard {
    using ECDSA for bytes32;

     /// @notice Reference to the admin contract for role management.
    DEF_ADMIN_contract public immutable adminContract;
    /// @notice Reference to the NFTBook contract for book ownership verification.
    NFTBookContract public immutable nftBookContract;
    /// @notice Reference to the marketplace contract.
    MarketplaceContract public marketplace;

    /// @notice Struct containing rights information.
    struct RightsInfo {
        address holder;
        uint256 expirationDate;
        string ipfsHash; // Hash of the rights contract stored off-chain
    }

    /// @notice Mapping of token ID to rights requests.
    mapping(uint256 => RightsRequestLib.RightsRequest) public rightsRequests;
    /// @notice Mapping of token ID to rights information.
    mapping(uint256 => RightsInfo) public rightsInfo;
//* ╔══════════════════════════════╗
//* ║            EVENTS            ║
//* ╚══════════════════════════════╝

    /// @notice Emitted when a rights request is initiated.
    event RequestInitiated(address indexed admin, uint256 indexed tokenId, uint256 requestDate);
    /// @notice Emitted when an author grants or declines approval for a rights request.
    event AuthorApprovalGranted(address indexed author, uint256 indexed tokenId, address indexed requester, bool approved, bool declined);
    /// @notice Emitted when rights are transferred.
    event RightsTransferred(uint256 indexed tokenId, address indexed from, address indexed to);
    /// @notice Emitted when a rights request is declined.
    event RightsRequestDeclined(uint256 indexed tokenId, address indexed initiator);
    /// @notice Emitted when rights information is updated.
    event RightsUpdated(uint256 indexed tokenId, address indexed holder, uint256 expirationDate, string ipfsHash);
    /// @notice Emitted when the marketplace contract is updated.
    event MarketplaceUpdated(address indexed newMarketplace);
    /// @notice Emitted when an author's signature is received.
    event AuthorSignatureReceived(address indexed author, uint256 indexed tokenId);

//* ╔══════════════════════════════╗
//* ║          MODIFIERS           ║
//* ╚══════════════════════════════╝

    /// @notice Ensures that only platform admins can call a function.
    modifier onlyPlatformAdmin() {
        console.log("Checking PLATFORM_ADMIN_ROLE for:", msg.sender);
        bool hasRole = adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender);
        console.log("Has PLATFORM_ADMIN_ROLE:", hasRole);
        require(hasRole, "Unauthorized");
        _;
    }

    /// @notice Ensures that only the author of a specific token can call a function.
    modifier onlyAuthor(uint256 tokenId) {
        (, address author, , , ) = nftBookContract.bookMetadata(tokenId);
        require(msg.sender == author, "Only the author can perform this action");
        _;
    }

//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝

    /**
     * @notice Initializes the contract with references to the admin and NFTBook contracts.
     * @param _adminContract Address of the admin contract.
     * @param _nftBookContract Address of the NFTBook contract.
     */
    constructor(address _adminContract, address _nftBookContract){
        require(_adminContract != address(0), "Invalid admin contract address");
        require(_nftBookContract != address(0), "Invalid NFTBook contract address");

        adminContract = DEF_ADMIN_contract(_adminContract);
        nftBookContract = NFTBookContract(_nftBookContract);
    }

//* ╔══════════════════════════════╗
//* ║          FUNCTIONS           ║
//* ╚══════════════════════════════╝

    /**
     * @notice Sets the marketplace contract address.
     * @param newMarketplace Address of the new marketplace contract.
     */
    function setMarketplace(address newMarketplace) external {
        require(address(marketplace) == address(0), "Marketplace already set");
        require(newMarketplace != address(0), "Invalid marketplace address");
        
        marketplace = MarketplaceContract(newMarketplace);
        emit MarketplaceUpdated(newMarketplace);
    }

    /**
     * @notice Initiates a rights transfer request.
     * @param tokenId ID of the NFT book.
     * @param requestDate Date of the request initiation.
     * @param buyer Address of the buyer requesting rights.
     */
    function initiateRequest(uint256 tokenId, uint256 requestDate, address buyer) public onlyPlatformAdmin{
        
        // Store request
        rightsRequests[tokenId] = RightsRequestLib.RightsRequest({
            requester: buyer,
            tokenId: tokenId,
            requestDate: requestDate,
            authorApproved: false,
            declined: false
        });

        emit RequestInitiated(msg.sender, tokenId, requestDate);
    }

    /**
     * @notice Allows an author to approve a rights request.
     * @param tokenId ID of the NFT book.
     */
    function authorApprove(uint256 tokenId) external onlyAuthor(tokenId) {
    require(rightsRequests[tokenId].requester != address(0), "No rights request found for this token ID");
    rightsRequests[tokenId].authorApproved = true;
    emit AuthorApprovalGranted(
        msg.sender,
        tokenId,
        rightsRequests[tokenId].requester,
        rightsRequests[tokenId].authorApproved,
        rightsRequests[tokenId].declined
    );
}

    /**
     * @notice Completes the transfer of rights.
     * @param tokenId ID of the NFT book.
     * @param expirationDate Expiration date of the transferred rights.
     * @param ipfsHash IPFS hash of the rights agreement.
     */
    function completeTransfer(uint256 tokenId, uint256 expirationDate, string calldata ipfsHash) external nonReentrant {
        RightsRequestLib.RightsRequest memory request = rightsRequests[tokenId];
        require(request.authorApproved, "Author approval required");
        require(!request.declined, "Request has been declined");
        require(request.requester != address(0), "No valid request");

        address currentHolder = nftBookContract.ownerOf(tokenId);

        // Transfer token
        nftBookContract.safeTransferFrom(currentHolder, request.requester, tokenId);

        // Update rights info
        rightsInfo[tokenId] = RightsInfo({
            holder: request.requester,
            expirationDate: expirationDate,
            ipfsHash: ipfsHash
        });

        emit RightsTransferred(tokenId, currentHolder, request.requester);
        emit RightsUpdated(tokenId, request.requester, expirationDate, ipfsHash);

        delete rightsRequests[tokenId];
    }

    /**
     * @notice Retrieves rights information for a specific NFT book.
     * @param tokenId ID of the NFT book.
     * @return Rights information associated with the book.
     */
    function getRightsInfo(uint256 tokenId) external view returns (RightsInfo memory) {
        return rightsInfo[tokenId];
    }
}
