// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DEF_ADMIN_contract.sol";
import "forge-std/console.sol";

/**
 * @title PaymentSplitterContract
 * @dev Handles payment distribution among multiple recipients with configurable splits and platform fees.
 */
contract PaymentSplitterContract is ReentrancyGuard {
    using Address for address payable;


    /// @notice Reference to the admin contract for role management.
    DEF_ADMIN_contract public immutable adminContract;

    /// @notice Denominator for percentage calculations.
    uint256 private constant PERCENTAGE_DENOMINATOR = 100;

    /// @notice Struct representing the split configuration for an author.
    struct SplitConfig {
        address[] recipients; ///< Addresses of the recipients.
        uint256[] percentages; ///< Corresponding split percentages.
        uint256 platformFee; ///< Fee taken by the platform in percentage.
    }

    /// @notice Mapping of author addresses to their split configurations.
    mapping(address => SplitConfig) public authorSplits;

//* ╔══════════════════════════════╗
//* ║            EVENTS            ║
//* ╚══════════════════════════════╝

    /// @notice Emitted when a payment is successfully split.
    event PaymentSplit(address indexed author, uint256 totalAmount);
    /// @notice Emitted when an author's split configuration is updated.
    event SplitConfigUpdated(address indexed author, address[] recipients, uint256[] percentages);
    /// @notice Emitted when an author's split configuration is deleted.
    event SplitConfigDeleted(address indexed author);
    /// @notice Emitted when the platform fee is updated.
    event PlatformFeeUpdated(address indexed admin, uint256 platformFee);
    /// @notice Emitted when a payment transfer fails.
    event PaymentFailed(address indexed recipient, uint256 amount);
    /// @notice Emitted when a payment transfer is successful.
    event FundsRescued(address indexed recipient, uint256 amount);

//* ╔══════════════════════════════╗
//* ║          MODIFIERS           ║
//* ╚══════════════════════════════╝

    /// @notice Ensures that only platform admins can call a function.
    modifier onlyPlatformAdmin() {
        require(adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender), "Unauthorized");
        _;
    }

    /// @notice Ensures that only authors or platform admins can call a function.
    modifier onlyAuthorOrAdmin() {
        require(
            adminContract.hasSpecificRole(adminContract.AUTHOR_ROLE(), msg.sender) || 
            adminContract.hasSpecificRole(adminContract.PLATFORM_ADMIN_ROLE(), msg.sender),
            "Unauthorized"
        );
        _;
    }

//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝

    /**
     * @notice Initializes the contract with the admin contract address.
     * @param _adminContract Address of the admin contract.
     */
    constructor(address _adminContract) {
        require(_adminContract != address(0), "Invalid admin contract address");
        adminContract = DEF_ADMIN_contract(_adminContract);
    }

//* ╔══════════════════════════════╗
//* ║          FUNCTIONS           ║
//* ╚══════════════════════════════╝

    /**
     * @notice Sets the platform fee for an author.
     * @param author The address of the author.
     * @param fee The platform fee in percentage (max 100).
     */
    function setPlatformFee(address author, uint256 fee) external onlyPlatformAdmin {
        require(fee <= PERCENTAGE_DENOMINATOR, "Fee exceeds 100%");
        authorSplits[author].platformFee = fee;
        emit PlatformFeeUpdated(msg.sender, fee);
    }

    /**
     * @notice Configures the payment split for an author.
     * @param author Address of the author.
     * @param recipients List of recipient addresses.
     * @param percentages Corresponding percentages for each recipient.
     */
    function setAuthorSplits(
        address author,
        address[] calldata recipients,
        uint256[] calldata percentages
     ) external onlyAuthorOrAdmin {
        require(author != address(0), "Invalid author address");
        require(recipients.length > 0, "Recipients cannot be empty");
        require(recipients.length == percentages.length, "Mismatched inputs");

        uint256 totalPercentage;
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercentage += percentages[i];
        }
        require(totalPercentage > 0, "Total percentages must exceed 0%");
        require(totalPercentage <= PERCENTAGE_DENOMINATOR, "Total percentages exceed 100%");

        authorSplits[author] = SplitConfig({
            recipients: recipients,
            percentages: percentages,
            platformFee: authorSplits[author].platformFee // Preserve existing platform fee
        });

        emit SplitConfigUpdated(author, recipients, percentages);
    }

    /**
     * @notice Deletes an author's split configuration.
     * @param author Address of the author.
     */
    function deleteAuthorSplits(address author) external onlyAuthorOrAdmin {
        delete authorSplits[author];
        emit SplitConfigDeleted(author);
    }

    /**
     * @notice Splits and distributes a payment according to an author's configuration.
     * @param author Address of the author receiving the payment.
     */
    function splitPayment(address author) external payable nonReentrant {
        require(author != address(0), "Invalid author address");
        SplitConfig memory config = authorSplits[author];

        require(msg.value > 0, "Payment required");
        require(config.recipients.length > 0, "No SplitConfig found for author");

        uint256 platformAmount = (msg.value * config.platformFee) / PERCENTAGE_DENOMINATOR;
        uint256 remainingAmount = msg.value - platformAmount;

        address payable platformWallet = payable(adminContract.getPlatformWallet());
        require(platformWallet != address(0), "Platform wallet not set");

        if (platformAmount > 0) {
            payable(msg.sender).sendValue(platformAmount);
        }

        for (uint256 i = 0; i < config.recipients.length; i++) {
            uint256 recipientAmount = (remainingAmount * config.percentages[i]) / PERCENTAGE_DENOMINATOR;

            if (recipientAmount > 0) {
                (bool success, ) = payable(config.recipients[i]).call{value: recipientAmount}("");
                if (!success) {
                    emit PaymentFailed(config.recipients[i], recipientAmount);
                }
            }
        }

        emit PaymentSplit(author, msg.value);
    }

    /**
     * @notice Retrieves the platform fee for a specific author.
     * @param author Address of the author.
     * @return Platform fee percentage.
     */
    function getPlatformFee(address author) external view returns (uint256) {
        return authorSplits[author].platformFee;
    }

    /**
     * @notice Retrieves the recipients for a specific author.
     * @param author Address of the author.
     * @return List of recipient addresses.
     */
    function getRecipients(address author) external view returns (address[] memory) {
        return authorSplits[author].recipients;
    }

    /**
     * @notice Retrieves the split percentages for a specific author.
     * @param author Address of the author.
     * @return List of split percentages.
     */
    function getPercentages(address author) external view returns (uint256[] memory) {
        return authorSplits[author].percentages;
    }

    /**
     * @notice Claims failed payments and sends them to the platform admin.
     */
    function claimFailedPayments() external onlyPlatformAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to claim");
        require(msg.sender != address(0), "Invalid recipient address");
        payable(msg.sender).transfer(balance);
    }

    /**
     * @notice Rescues funds from the contract.
     */ 
    function rescueFunds() external onlyPlatformAdmin {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to rescue");
        require(msg.sender != address(0), "Invalid recipient address");
        payable(msg.sender).transfer(balance);

        emit FundsRescued(msg.sender, balance);
    }

}
