// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

/**
 * @title RightsRequestLib
 * @dev Library defining the structure for rights transfer requests.
 */
library RightsRequestLib {
    /**
     * @notice Represents a request to transfer rights of an NFT book.
     * @dev Used in `RightsManagerContract` to track approval and completion of rights transfers.
     * @param requester The address requesting the rights transfer.
     * @param tokenId The ID of the NFT book associated with the request.
     * @param requestDate The timestamp of when the request was initiated.
     * @param authorApproved Indicates whether the author has approved the request.
     * @param declined Indicates whether the request has been declined.
     */
    struct RightsRequest {
        address requester;
        uint256 tokenId;
        uint256 requestDate;
        bool authorApproved;
        bool declined;
    }
}
