// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "../src/PaymentSplitterContract.sol";
import "../src/DEF_ADMIN_contract.sol";

contract PaymentSplitterContractTest is Test {
    PaymentSplitterContract public paymentSplitter;
    DEF_ADMIN_contract public adminContract;

    address public platformAdmin = address(0x1);
    address public author = address(0x2);
    address public recipient1 = address(0x3);
    address public recipient2 = address(0x4);
    address public unauthorized = address(0x5);
    address public PlatformWallet = address(0x6);

    receive() external payable {}

function setUp() public {
    // Deploy the admin contract
    adminContract = new DEF_ADMIN_contract(platformAdmin, payable(PlatformWallet));

    // Grant PLATFORM_ADMIN_ROLE to platformAdmin
    vm.prank(platformAdmin);
    adminContract.grantPlatformAdmin(platformAdmin);

    // Grant roles
    vm.prank(platformAdmin);
    adminContract.grantAuthorRole(author);

    // Deploy the PaymentSplitterContract
    paymentSplitter = new PaymentSplitterContract(address(adminContract));
}

    function testSetPlatformFee() public {
        vm.prank(platformAdmin);
        paymentSplitter.setPlatformFee(author, 10); // Set platform fee to 10%

        uint256 fee = paymentSplitter.getPlatformFee(author);
        assertEq(fee, 10);
    }

    function testCannotSetPlatformFeeAbove100Percent() public {
        vm.prank(platformAdmin);
        vm.expectRevert("Fee exceeds 100%");
        paymentSplitter.setPlatformFee(author, 110); // Exceeds 100%
    }

    function testUnauthorizedCannotSetPlatformFee() public {
        vm.prank(unauthorized);
        vm.expectRevert("Unauthorized");
        paymentSplitter.setPlatformFee(author, 10);
    }

    function testSetAuthorSplits() public {
        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 60; 
        percentages[1] = 40; 

        vm.prank(author);
        paymentSplitter.setAuthorSplits(author, recipients, percentages);

        address[] memory retrievedRecipients = paymentSplitter.getRecipients(author);
        uint256[] memory retrievedPercentages = paymentSplitter.getPercentages(author);

        assertEq(retrievedRecipients[0], recipient1);
        assertEq(retrievedRecipients[1], recipient2);
        assertEq(retrievedPercentages[0], 60);
        assertEq(retrievedPercentages[1], 40);
    }

  function testCannotSetSplitsWithMismatchedArrays() public {
    address [] memory recipients = new address[](1);
    recipients[0] = recipient1;

    uint256 [] memory percentages = new uint256[](2);
    percentages[0] = 60;
    percentages[1] = 40;

    vm.prank(author);
    vm.expectRevert("Mismatched inputs");
    paymentSplitter.setAuthorSplits(author, recipients, percentages);
}

    function testCannotSetSplitsExceeding100Percent() public {
        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 70; 
        percentages[1] = 40;

        vm.prank(author);
        vm.expectRevert("Total percentages exceed 100%");
        paymentSplitter.setAuthorSplits(author, recipients, percentages);
    }
    function testCannotSplitPaymentWithZeroValue() public {
        vm.expectRevert("Payment required");
        paymentSplitter.splitPayment(author);
    }

    function testSplitPayment() public {
        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 60;
        percentages[1] = 40; 

         vm.prank(author);
            paymentSplitter.setAuthorSplits(author, recipients, percentages);

            vm.prank(platformAdmin);
            paymentSplitter.setPlatformFee(author, 10);

            vm.deal(address(this), 1 ether);

        
            vm.prank(address(this));
            paymentSplitter.splitPayment{value: 1 ether}(author);

            assertEq(recipient1.balance, 0.54 ether); // 60% of 90% remaining
            assertEq(recipient2.balance, 0.36 ether); // 40% of 90% remaining
            assertEq(address(this).balance, 0.1 ether); // 10% platform fee
    }


    function testSetSplitsWithEmptyRecipients() public {
        address [] memory recipients = new address[](0);
        uint256 [] memory percentages = new uint256[](0);

        vm.prank(author);
        vm.expectRevert("Recipients cannot be empty");
        paymentSplitter.setAuthorSplits(author, recipients, percentages);
    }

    function testSetSplitsWithZeroPercentages() public {
        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 0;
        percentages[1] = 0;

        vm.prank(author);
        vm.expectRevert("Total percentages must exceed 0%");
        paymentSplitter.setAuthorSplits(author, recipients, percentages);
    }

    function testSplitPaymentWithNoConfig() public {
        vm.deal(address(this), 1 ether);

        vm.expectRevert(); 
        vm.prank(address(this));
        paymentSplitter.splitPayment{value: 1 ether}(author);
    }

    function testSplitPaymentWithZeroPlatformFee() public {
        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 50;
        percentages[1] = 50;

        vm.prank(author);
        paymentSplitter.setAuthorSplits(author, recipients, percentages);

        vm.prank(platformAdmin);
        paymentSplitter.setPlatformFee(author, 0); // No platform fee

        vm.deal(address(this), 1 ether);

        vm.prank(address(this));
        paymentSplitter.splitPayment{value: 1 ether}(author);

        assertEq(recipient1.balance, 0.5 ether); // 50% of 1 ether
        assertEq(recipient2.balance, 0.5 ether); // 50% of 1 ether
        assertEq(address(this).balance, 0, "Platform fee incorrect");
    }

    function testFuzzSplitPayment(uint256 amount) public {
        vm.assume(amount > 0 && amount <= 1 ether);

        address [] memory recipients = new address[](2);
        recipients[0] = recipient1;
        recipients[1] = recipient2;

        uint256 [] memory percentages = new uint256[](2);
        percentages[0] = 60;
        percentages[1] = 40;

        vm.prank(author);
        paymentSplitter.setAuthorSplits(author, recipients, percentages);

        vm.prank(platformAdmin);
        paymentSplitter.setPlatformFee(author, 10);

        vm.deal(address(this), amount);

        vm.prank(address(this));
        paymentSplitter.splitPayment{value: amount}(author);

        uint256 remainingAmount = (amount * 90) / 100; // 90% after platform fee
        uint256 recipient1Expected = (remainingAmount * 60) / 100;
        uint256 recipient2Expected = (remainingAmount * 40) / 100;

        assertApproxEqAbs(recipient1.balance, recipient1Expected, 1);
        assertApproxEqAbs(recipient2.balance, recipient2Expected, 1);
    }
}


//!!  ADD MORE FUZZZZZZZZZZZZZZZŹ