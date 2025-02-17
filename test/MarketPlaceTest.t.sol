// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "../src/MarketPlace_contract.sol";
import "../src/NFTBookContract.sol";
import "../src/DEF_ADMIN_contract.sol";
import "../src/PaymentSplitterContract.sol";
import "../src/RightsManagerContract.sol";

contract MarketplaceContractTest is Test {
    MarketplaceContract public marketplace;
    NFTBookContract public nftBook;
    DEF_ADMIN_contract public adminContract;
    PaymentSplitterContract public paymentSplitter;
    RightsManagerContract public rightsManager;

    address public defaultAdmin = address(0x1);
    address public platformAdmin = address(0x2);
    address public author = address(0x3);
    address public buyer = address(0x4);
    address public unauthorized = address(0x5);
    address public defaultPlatformWallet = address(0x6);

    string public constant BOOK_TITLE = "Sample Book";
    string public constant BOOK_HASH = "ipfs://bookhash";
    uint256 public constant BOOK_PRICE = 1 ether;
    uint256 public bookTokenId;

    function setUp() public {
        // ✅ Deploy Admin Contract
        adminContract = new DEF_ADMIN_contract(defaultAdmin, payable(defaultPlatformWallet));

        // ✅ Assign Roles
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.prank(platformAdmin);
        adminContract.grantAuthorRole(author);

        // ✅ Deploy Payment Splitter
        paymentSplitter = new PaymentSplitterContract(address(adminContract));

        // ✅ Deploy NFT Book Contract
        nftBook = new NFTBookContract(address(adminContract));

        // ✅ Deploy Rights Manager Contract
        rightsManager = new RightsManagerContract(address(adminContract), address(nftBook));

        // ✅ Deploy Marketplace Contract
        marketplace = new MarketplaceContract(address(adminContract), address(paymentSplitter));

        // ✅ Set RightsManagerContract in Marketplace
        vm.prank(platformAdmin);
        marketplace.setRightsManager(address(rightsManager));

        // ✅ Author Requests to Publish an NFT Book
        vm.prank(author);
        nftBook.requestPublishBook(author, BOOK_TITLE, BOOK_HASH);

        // ✅ Platform Admin Approves Publishing (Mints the NFT)
        vm.prank(platformAdmin);
        nftBook.approvePublishing(1);

        bookTokenId = nftBook.getNextTokenId() - 1;

        // ✅ Author's payment split setup (Required for purchase tests)
        address[] memory recipients = new address[](1); 
        recipients[0] = author;
        uint256[] memory percentages = new uint256 [](1);
        percentages[0] = 100; // 100% of the payment goes to the author

        vm.prank(author);
        paymentSplitter.setAuthorSplits(author, recipients, percentages);

        // ✅ Author Approves Marketplace to Transfer NFT
        vm.prank(author);
        nftBook.approve(address(marketplace), bookTokenId);
    }

   function testAuthorCanListNFT() public {
    vm.prank(author);
    marketplace.listToken(bookTokenId, BOOK_PRICE);

    MarketplaceContract.Listing memory listing = marketplace.getListing(bookTokenId);
    assertEq(listing.tokenId, bookTokenId);
    assertEq(listing.price, BOOK_PRICE);
    assertTrue(listing.active);
}

    function testNonOwnerCannotListNFT() public {
        vm.prank(unauthorized);
        vm.expectRevert("You do not own this token");
        marketplace.listToken(bookTokenId, BOOK_PRICE);
    }

    function testSellerCanUpdateListing() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        uint256 newPrice = 2 ether;
        vm.prank(author);
        marketplace.updateListing(bookTokenId, newPrice);

        MarketplaceContract.Listing memory listing = marketplace.getListing(bookTokenId);
        assertEq(listing.price, newPrice);
    }

    function testNonSellerCannotUpdateListing() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        vm.prank(unauthorized);
        vm.expectRevert("Not the seller");
        marketplace.updateListing(bookTokenId, 2 ether);
    }

    function testSellerCanRemoveListing() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        vm.prank(author);
        marketplace.removeListing(bookTokenId);

        MarketplaceContract.Listing memory listing = marketplace.getListing(bookTokenId);
        assertEq(listing.seller, address(0));
        assertFalse(listing.active);
    }

    function testNonSellerCannotRemoveListing() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        vm.prank(unauthorized);
        vm.expectRevert("Not the seller");
        marketplace.removeListing(bookTokenId);
    }

    function testOnlyAdminCanSetRightsManager() public {
        vm.prank(unauthorized);
        vm.expectRevert("Unauthorized");
        marketplace.setRightsManager(address(buyer));

        vm.prank(platformAdmin);
        marketplace.setRightsManager(address(buyer));

        assertEq(address(marketplace.rightsManagerContract()), address(buyer));
    }

    function testCannotPurchaseWithInsufficientFunds() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        vm.deal(buyer, BOOK_PRICE / 2); // ✅ Ensure buyer has less than required amount
        vm.prank(buyer);
        vm.expectRevert("Insufficient payment");
        marketplace.purchaseToken{value: BOOK_PRICE / 2}(bookTokenId);
    }



//!! FIX UNDER AUDIT

/*
        function testBuyerCanPurchaseNFT() public {
        vm.prank(author);
        marketplace.listToken(bookTokenId, BOOK_PRICE);

        vm.deal(buyer, BOOK_PRICE); // Ensure buyer has enough ETH
        vm.prank(buyer);
        marketplace.purchaseToken{value: BOOK_PRICE}(bookTokenId);

        assertEq(nftBook.ownerOf(bookTokenId), buyer);

        MarketplaceContract.Listing memory listing = marketplace.getListing(bookTokenId);
        address seller = listing.seller;
        bool active = listing.active;
        assertEq(seller, address(0));
        assertFalse(active);
    }

    function testCannotPurchaseInactiveListing() public {
    // ✅ Ensure the listing is actually inactive
    MarketplaceContract.Listing memory listing = marketplace.getListing(bookTokenId);
    assertFalse(listing.active, "Expected listing to be inactive before purchase attempt");

    vm.prank(buyer);
    vm.expectRevert("Listing is not active");
    marketplace.purchaseToken{value: BOOK_PRICE}(bookTokenId);
}

*/

}

