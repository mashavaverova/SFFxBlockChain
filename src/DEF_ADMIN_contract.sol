// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "forge-std/console.sol";

/**
 * @title DEF_ADMIN_contract
 * @dev Manages role-based access control with administrative functions.
 * @notice This contract implements role management for platform administrators, fund managers, and authors.
 */
contract DEF_ADMIN_contract is AccessControl {
    /// @notice Role for platform administrators
    bytes32 public constant PLATFORM_ADMIN_ROLE = keccak256("PLATFORM_ADMIN_ROLE");
    /// @notice Role for fund managers
    bytes32 public constant FUND_MANAGER_ROLE = keccak256("FUND_MANAGER_ROLE");
    /// @notice Role for authors
    bytes32 public constant AUTHOR_ROLE = keccak256("AUTHOR_ROLE");

    /// @notice Default admin of the contract
    address public immutable defaultAdmin;
    /// @notice Wallet address for platform funds
    address payable private platformWallet;

//* ╔══════════════════════════════╗
//* ║            EVENTS            ║
//* ╚══════════════════════════════╝

    /// @notice Emitted when a Platform Admin role is granted.
    event PlatformAdminGranted(address indexed account, address indexed sender);
    /// @notice Emitted when a Platform Admin role is revoked.
    event PlatformAdminRevoked(address indexed account, address indexed sender);
    /// @notice Emitted when a Fund Manager role is granted.
    event FundManagerGranted(address indexed account, address indexed sender);
    /// @notice Emitted when a Fund Manager role is revoked.
    event FundManagerRevoked(address indexed account, address indexed sender);
    /// @notice Emitted when an Author role is granted.
    event AuthorGranted(address indexed account, address indexed sender);
    /// @notice Emitted when an Author role is revoked.
    event AuthorRevoked(address indexed account, address indexed sender);
    /// @notice Emitted when the platform wallet address is updated.
    event PlatformWalletUpdated(address indexed admin, address newWallet);

//!! ╔══════════════════════════════╗
//!! ║            ERRORS            ║
//!! ╚══════════════════════════════╝

    /// @notice Error for unauthorized access.
    error Unauthorized(address account, bytes32 requiredRole);
    /// @notice Error for invalid address.
    error InvalidAddress(address account);
//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝
    
    /**
    * @notice Initializes the contract with a default admin and an initial platform wallet.
    * @param _defaultAdmin Address of the default administrator.
    * @param initialPlatformWallet Address of the initial platform wallet.
    */
    constructor(address _defaultAdmin, address payable initialPlatformWallet) {

        if (_defaultAdmin == address(0)) {
            revert InvalidAddress(_defaultAdmin);
        }

        defaultAdmin = _defaultAdmin;
        platformWallet = initialPlatformWallet;
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);

        _setRoleAdmin(PLATFORM_ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(FUND_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(AUTHOR_ROLE, PLATFORM_ADMIN_ROLE);
    }

//* ╔══════════════════════════════╗
//* ║          FUNCTIONS           ║
//* ╚══════════════════════════════╝

    /**
     * @notice Validates that an address is not the zero address.
     * @param account Address to validate.
     */
    function validateAddress(address account) internal pure {
        if (account == address(0)) {
            revert InvalidAddress(account);
        }
    }

    /**
     * @notice Grants the Platform Admin role to an account.
     * @param account Address to be granted the role.
     */
    function grantPlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        validateAddress(account);
        grantRole(PLATFORM_ADMIN_ROLE, account);
        emit PlatformAdminGranted(account, msg.sender); // Emit event
    }

    /**
     * @notice Revokes the Platform Admin role from an account.
     * @param account Address to have the role revoked.
     */
    function revokePlatformAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        validateAddress(account);
        revokeRole(PLATFORM_ADMIN_ROLE, account);
        emit PlatformAdminRevoked(account, msg.sender); // Emit event
    }

    /**
     * @notice Grants the Fund Manager role to an account.
     * @param account Address to be granted the role.
     */
    function grantFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        validateAddress(account);
        grantRole(FUND_MANAGER_ROLE, account);
        emit FundManagerGranted(account, msg.sender); // Emit event
    }

    /**
     * @notice Revokes the Fund Manager role from an account.
     * @param account Address to have the role revoked.
     */
    function revokeFundManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        validateAddress(account);
        revokeRole(FUND_MANAGER_ROLE, account);
        emit FundManagerRevoked(account, msg.sender); // Emit event
    }

    /**
     * @notice Grants the Author role to an account.
     * @param account Address to be granted the role.
     */
    function grantAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE) {
        validateAddress(account);
        grantRole(AUTHOR_ROLE, account);
        emit AuthorGranted(account, msg.sender); // Emit event
    }

    /**
     * @notice Revokes the Author role from an account.
     * @param account Address to have the role revoked.
     */
    function revokeAuthorRole(address account) external onlyRole(PLATFORM_ADMIN_ROLE) {
        validateAddress(account);
        revokeRole(AUTHOR_ROLE, account);
        emit AuthorRevoked(account, msg.sender); // Emit event
    }

    /**
     * @notice Checks if an account has a specific role.
     * @param role The role to check.
     * @param account The address to check.
     * @return True if the account has the role, otherwise false.
     */
    function hasSpecificRole(bytes32 role, address account) external view returns (bool) {
        return hasRole(role, account);
    }

    /**
     * @notice Overrides `_checkRole` to use custom error handling.
     * @param role Role to check.
     * @param account Account to check.
     */
    function _checkRole(bytes32 role, address account) internal view virtual override {
        if (!hasRole(role, account)) {
            revert Unauthorized(account, role);
        }
    }

    /**
     * @notice Updates the platform wallet address.
     * @param newWallet New wallet address.
     */
    function setPlatformWallet(address payable newWallet) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newWallet != address(0), "New wallet address cannot be zero");
        platformWallet = newWallet;
        emit PlatformWalletUpdated(msg.sender, newWallet);
    }

    /**
     * @notice Retrieves the platform wallet address.
     * @return The current platform wallet address.
     */
    function getPlatformWallet() external view returns (address payable) {
        return platformWallet;
    }
}
