// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/**
 * @title IRightsManagerContract
 * @dev Interface for managing rights transfers associated with NFT books.
 */
interface IRightsManagerContract {
    
    /**
     * @notice Completes the transfer of rights for a given NFT book.
     * @dev This function should be called to finalize a rights transfer, setting an expiration date and an IPFS hash for reference.
     * @param tokenId The unique identifier of the NFT book whose rights are being transferred.
     * @param expirationDate The timestamp (in seconds) when the transferred rights will expire.
     * @param ipfsHash A string containing the IPFS hash of the associated metadata.
     */
    function completeTransfer(uint256 tokenId, uint256 expirationDate, string calldata ipfsHash) external;

    /**
     * @notice Retrieves the address of the NFT book contract associated with this rights manager.
     * @return The address of the NFT book contract.
     */
    function nftBookContract() external view returns (address);
}
