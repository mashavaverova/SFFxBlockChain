// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "../src/NFTBookContract.sol";
import "../src/DEF_ADMIN_contract.sol";

contract NFTBookContractTest is Test {
    NFTBookContract public nftBookContract;
    DEF_ADMIN_contract public adminContract;

    address public defaultAdmin = address(0x1);
    address public platformAdmin = address(0x2);
    address public author = address(0x3);
    address public unauthorized = address(0x4);
    address public bookRecipient = address(0x5);
    address public defaultPlatformWallet = address(0x6);

    string public constant BOOK_TITLE = "Sample Book";
    string public constant BOOK_HASH = "ipfs://bookhash";

    error ERC721NonexistentToken(uint256 tokenId);





    function setUp() public {
        // Deploy the admin contract
        adminContract = new DEF_ADMIN_contract(defaultAdmin, payable(defaultPlatformWallet));

        // Grant roles via the admin contract
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.prank(platformAdmin);
        adminContract.grantAuthorRole(author);

        // Deploy the NFTBookContract
        nftBookContract = new NFTBookContract(address(adminContract));
    }

    function testAdminCanPublishForUnregistered() public {
        vm.prank(platformAdmin);
        nftBookContract.publishForUnregistered(bookRecipient, BOOK_TITLE, BOOK_HASH);

        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        assertEq(nftBookContract.ownerOf(tokenId), bookRecipient);

        // Verify metadata
        (string memory title, address metadataAuthor, string memory bookHash, , uint256 datePublished) =
            nftBookContract.bookMetadata(tokenId);

        assertEq(title, BOOK_TITLE);
        assertEq(metadataAuthor, address(0)); // Unregistered author
        assertEq(bookHash, BOOK_HASH);
        assertGt(datePublished, 0);
    }

    function testUnauthorizedCannotRequestPublishing() public {
        vm.prank(unauthorized);
        vm.expectRevert("Unauthorized");
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);
    }

    function testCannotApprovePublishingWithInvalidRequest() public {
        vm.expectRevert("Invalid request");
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(9999); // Non-existent requestId
    }

    function testCannotApproveDeletionWithInvalidRequest() public {
        vm.expectRevert("Invalid request");
        vm.prank(platformAdmin);
        nftBookContract.approveDeletion(9999); // Non-existent requestId
    }

    function testOnlyAdminCanMarkAsPurchased() public {
        vm.prank(unauthorized);
        vm.expectRevert("Unauthorized");
        nftBookContract.markAsPurchased(1);
    }

    function testCannotPublishForUnregisteredWithInvalidInputs() public {
        vm.prank(platformAdmin);
        vm.expectRevert("Title cannot be empty");
        nftBookContract.publishForUnregistered(bookRecipient, "", BOOK_HASH);

        vm.prank(platformAdmin);
        vm.expectRevert("Book hash cannot be empty");
        nftBookContract.publishForUnregistered(bookRecipient, BOOK_TITLE, "");

        vm.prank(platformAdmin);
        vm.expectRevert("Recipient cannot be zero address");
        nftBookContract.publishForUnregistered(address(0), BOOK_TITLE, BOOK_HASH);
    }

    ///  Edge cases
    function testCannotPublishWithEmptyTitle() public {
        vm.expectRevert("Title cannot be empty");
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, "", BOOK_HASH);
    }

    function testCannotPublishWithEmptyBookHash() public {
        vm.expectRevert("Book hash cannot be empty");
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, "");
    }

    function testCannotPublishWithInvalidRecipient() public {
        vm.expectRevert("Recipient cannot be zero address");
        vm.prank(author);
        nftBookContract.requestPublishBook(address(0), BOOK_TITLE, BOOK_HASH);
    }

    function testCannotDeleteNonExistentToken() public {
        uint256 nonExistentTokenId = 9999;

        // Attempt to delete non-existent token
        vm.expectRevert("Invalid request");
        vm.prank(platformAdmin);
        nftBookContract.approveDeletion(nonExistentTokenId);
    }

    function testUnauthorizedCannotRequestPublishBook() public {
        vm.expectRevert("Unauthorized");
        vm.prank(unauthorized);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);
    }

    function testUnauthorizedCannotApprovePublishing() public {
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);
        uint256 requestId = nftBookContract.getNextTokenId() - 1;

        vm.expectRevert("Unauthorized");
        vm.prank(unauthorized);
        nftBookContract.approvePublishing(requestId);
    }

    function testUnauthorizedCannotApproveDeletion() public {
        uint256 invalidRequestId = 1;

        vm.expectRevert("Unauthorized");
        vm.prank(unauthorized);
        nftBookContract.approveDeletion(invalidRequestId);
    }

    function testAuthorCanRequestAndPublishBook() public {
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        uint256 requestId = 1; // First request should have ID 1

        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(requestId);

        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Check NFT ownership
        assertEq(nftBookContract.ownerOf(tokenId), bookRecipient);

        // Check metadata
        (string memory title, address metadataAuthor, string memory bookHash, , uint256 datePublished) =
            nftBookContract.bookMetadata(tokenId);

        assertEq(title, BOOK_TITLE);
        assertEq(metadataAuthor, author);
        assertEq(bookHash, BOOK_HASH);
        assertGt(datePublished, 0);
    }

    function testOnlyAuthorCanRequestDeleteBook() public {
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);
        
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Unauthorized user tries to request deletion
        vm.expectRevert("Unauthorized");
        vm.prank(unauthorized);
        nftBookContract.requestDeleteBook(tokenId);
    }

    function testCannotDeletePurchasedBook() public {
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Mark as purchased
        vm.prank(platformAdmin);
        nftBookContract.markAsPurchased(tokenId);

        // Attempt to delete it
        vm.expectRevert("Book has been purchased");
        vm.prank(author);
        nftBookContract.requestDeleteBook(tokenId);
    }

    function testUnauthorizedCannotRequestDeletion() public {
        // Step 1: Author publishes a book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);
        
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Step 2: Unauthorized user tries to request deletion
        vm.prank(unauthorized);
        vm.expectRevert("Unauthorized"); // Ensure revert message matches contract logic
        nftBookContract.requestDeleteBook(tokenId);
    }

    function testAdminCanApprovePublishingRequest() public {
        // Step 1: Author requests to publish a book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        // Verify that the request was stored correctly
        (address storedAuthor, , string memory storedTitle, string memory storedHash, ) =
            nftBookContract.publishingRequests(1);
        assertEq(storedAuthor, author);
        assertEq(storedTitle, BOOK_TITLE);
        assertEq(storedHash, BOOK_HASH);

        // Step 2: Platform admin approves publishing (minting the NFT)
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);

        // Step 3: Retrieve minted tokenId
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Step 4: Verify NFT ownership
        assertEq(nftBookContract.ownerOf(tokenId), bookRecipient);

        // Step 5: Verify metadata stored correctly
        (string memory title, address metadataAuthor, string memory bookHash, , uint256 datePublished) =
            nftBookContract.bookMetadata(tokenId);

        assertEq(title, BOOK_TITLE);
        assertEq(metadataAuthor, author);
        assertEq(bookHash, BOOK_HASH);
        assertGt(datePublished, 0); // Ensure timestamp is set
    }

    function testAuthorCanRequestDeletion() public {
        // Step 1: Author requests to publish a book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        // Step 2: Platform admin approves publishing (minting the NFT)
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Step 3: Author requests deletion
        vm.prank(author);
        nftBookContract.requestDeleteBook(tokenId);

        // Step 4: Verify deletion request is stored correctly
        (address deletionAuthor, uint256 deletionTokenId) = nftBookContract.deletionRequests(1);
        assertEq(deletionAuthor, author);
        assertEq(deletionTokenId, tokenId);
    }
    function testGetNextTokenId() public {
        // Step 1: Check the initial token ID (should be 1 since no tokens have been minted yet)
        uint256 expectedNextTokenId = 1;
        assertEq(nftBookContract.getNextTokenId(), expectedNextTokenId);

        // Step 2: Author requests to publish a book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        // Step 3: Platform admin approves publishing (minting the NFT)
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);

        // Step 4: Verify the next token ID has incremented
        expectedNextTokenId = 2;
        assertEq(nftBookContract.getNextTokenId(), expectedNextTokenId);

        // Step 5: Publish another book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, "Another Book", "ipfs://anotherhash");

        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(2);

        // Step 6: Verify next token ID has incremented again
        expectedNextTokenId = 3;
        assertEq(nftBookContract.getNextTokenId(), expectedNextTokenId);
    }


    function testAdminCanApproveDeletion() public {
        // Step 1: Author requests to publish a book
        vm.prank(author);
        nftBookContract.requestPublishBook(bookRecipient, BOOK_TITLE, BOOK_HASH);

        // Step 2: Platform admin approves the book (minting the NFT)
        vm.prank(platformAdmin);
        nftBookContract.approvePublishing(1);
        uint256 tokenId = nftBookContract.getNextTokenId() - 1;

        // Step 3: Author requests deletion
        vm.prank(author);
        nftBookContract.requestDeleteBook(tokenId);

        // Step 4: Platform admin approves the deletion
        vm.prank(platformAdmin);
        nftBookContract.approveDeletion(1);

        // Step 5: Verify NFT is burned (match OpenZeppelin's new revert message)
        vm.expectRevert(abi.encodeWithSelector(ERC721NonexistentToken.selector, tokenId));
        nftBookContract.ownerOf(tokenId);
    }

    }
