// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./DEF_ADMIN_contract.sol";

/**
 * @title FundManagerContract
 * @dev Manages fund-related operations with role-based access control. Fund managers can request withdrawals and transfers,
 * while only the default admin can approve them. Includes reentrancy protection.
 */
contract FundManagerContract is ReentrancyGuard {
    /// @notice Reference to the admin contract managing roles and permissions.
    DEF_ADMIN_contract public immutable adminContract;

    /// @notice Address of the default admin extracted from the admin contract.
    address public immutable defaultAdmin;

    /// @notice Mapping to track whether a withdrawal has been approved for a recipient.
    /// @dev The key is the recipient's address, and the value is `true` if the withdrawal is approved, otherwise `false`.
    mapping(address => bool) public withdrawalApproved;

    /// @notice Mapping to track whether a fund transfer has been approved for a recipient.
    /// @dev The key is the recipient's address, and the value is `true` if the transfer is approved, otherwise `false`.
    mapping(address => bool) public fundTransferApproved;

//* ╔══════════════════════════════╗
//* ║            EVENTS            ║
//* ╚══════════════════════════════╝

    /// @notice Emitted when funds are added to the contract.
    event FundsAdded(address indexed sender, uint256 amount);
    /// @notice Emitted when funds are withdrawn from the contract.
    event FundsWithdrawn(address indexed recipient, uint256 amount);
    /// @notice Emitted when funds are sent to a recipient.
    event FundsSent(address indexed recipient, uint256 amount);
    /// @notice Emitted when a fund manager requests a withdrawal.
    event WithdrawalRequested(address indexed recipient, uint256 amount);
    /// @notice Emitted when the default admin approves a withdrawal request.
    event WithdrawalApproved(address indexed recipient);
    /// @notice Emitted when a fund manager requests a fund transfer.
    event FundTransferRequested(address indexed recipient, uint256 amount);
    /// @notice Emitted when the default admin approves a fund transfer request.
    event FundTransferApproved(address indexed recipient);

//* ╔══════════════════════════════╗
//* ║          MODIFIERS           ║
//* ╚══════════════════════════════╝

    /// @notice Ensures that only the default admin can call a function.
    modifier onlyAdmin() {
        require(adminContract.hasSpecificRole(adminContract.DEFAULT_ADMIN_ROLE(), msg.sender), "Only default admin can perform this action");
        _;
    }

    /// @notice Ensures that only a fund manager can call a function.
 modifier onlyFundManager() {
        require(adminContract.hasSpecificRole(adminContract.FUND_MANAGER_ROLE(), msg.sender), "Only fund manager can perform this action");
        _;
    }

//* ╔══════════════════════════════╗
//* ║         CONSTRUCTOR          ║
//* ╚══════════════════════════════╝
    /**
     * @notice Initializes the contract with the admin contract address.
     * @param _adminContract The address of the DEF_ADMIN_contract that manages roles.
     */
    constructor(address _adminContract) {
        require(_adminContract != address(0), "Invalid admin contract address");
        adminContract = DEF_ADMIN_contract(_adminContract);
        defaultAdmin = adminContract.defaultAdmin();
    }

//* ╔══════════════════════════════╗
//* ║          FUNCTIONS           ║
//* ╚══════════════════════════════╝

    /**
     * @notice Allows a fund manager to request a withdrawal.
     * @param recipient The address to receive the funds if approved.
     * @param amount The amount of ETH requested for withdrawal.
     */
    function requestWithdrawal(address recipient, uint256 amount) external onlyFundManager {
        emit WithdrawalRequested(recipient, amount);
    }

    /**
     * @notice Allows the default admin to approve a withdrawal request.
     * @param recipient The address whose withdrawal request is being approved.
     */
    function approveWithdrawal(address recipient) external onlyAdmin {
        withdrawalApproved[recipient] = true;
        emit WithdrawalApproved(recipient);
    }

    /**
     * @notice Allows a fund manager to request a fund transfer.
     * @param recipient The address to receive the funds if approved.
     * @param amount The amount of ETH requested for transfer.
     */
    function requestFundTransfer(address recipient, uint256 amount) external onlyFundManager {
        emit FundTransferRequested(recipient, amount);
    }

    /**
     * @notice Allows the default admin to approve a fund transfer request.
     * @param recipient The address whose fund transfer request is being approved.
     */
    function approveFundTransfer(address recipient) external onlyAdmin {
        fundTransferApproved[recipient] = true;
        emit FundTransferApproved(recipient);
    }

    /**
     * @notice Allows anyone to add funds to the contract.
     */
    function addFunds() external payable {
        require(msg.value > 0, "Must send ETH");
        emit FundsAdded(msg.sender, msg.value);
    }

    /**
     * @notice Allows a fund manager to withdraw funds after approval.
     * @dev Uses reentrancy guard to prevent attacks.
     * @param recipient The address that will receive the withdrawn funds.
     * @param amount The amount of ETH to withdraw.
     */
    function withdrawFunds(address payable recipient, uint256 amount) external nonReentrant onlyFundManager  {
        require(amount > 0, "Invalid withdrawal amount"); 
        require(recipient != address(0), "Invalid recipient address");
        require(withdrawalApproved[recipient], "Withdrawal not approved");
        require(address(this).balance >= amount, "Insufficient contract balance");

        withdrawalApproved[recipient] = false;

        (bool success, ) = recipient.call{gas: 5000, value: amount}("");
        require(success, "Transfer failed");

        emit FundsWithdrawn(recipient, amount);
    }

    /**
     * @notice Allows a fund manager to send funds after approval.
     * @dev Uses reentrancy guard to prevent attacks.
     * @param recipient The address that will receive the funds.
     * @param amount The amount of ETH to send.
     */
    function sendFunds(address payable recipient, uint256 amount) external nonReentrant onlyFundManager {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Invalid transfer amount");
        require(fundTransferApproved[recipient], "Fund transfer not approved");
        require(address(this).balance >= amount, "Insufficient contract balance");

        fundTransferApproved[recipient] = false;

        recipient.transfer(amount);

        emit FundsSent(recipient, amount);
    }

    /**
     * @notice Allows the contract to receive ETH directly.
     */
        receive() external payable {
            emit FundsAdded(msg.sender, msg.value);
        }
}
