// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "../src/FundManagerContract.sol";
import "../src/DEF_ADMIN_contract.sol";

contract FundManagerContractTest is Test {
    FundManagerContract public fundManager;
    DEF_ADMIN_contract public adminContract;

    address public defaultAdmin = address(0x1);
    address public fundManagerRole = address(0x2);
    address public secondFundManager = address(0x5);
    address public recipient = address(0x3);
    address public unauthorized = address(0x4);
    address public selfDestructContract;
    address public defaultPlatformWallet = address(0x6);

    uint256 public testAmount = 1 ether;

    event WithdrawalRequested(address indexed recipient, uint256 amount);
    event WithdrawalApproved(address indexed recipient);
    event FundsSent(address indexed recipient, uint256 amount);

    function setUp() public {
        adminContract = new DEF_ADMIN_contract(defaultAdmin, payable(defaultPlatformWallet));
        
        vm.prank(defaultAdmin);
        adminContract.grantFundManager(fundManagerRole);
        
        fundManager = new FundManagerContract(address(adminContract));


    }

    //** UNIT TESTS */

    function testAddFunds() public {
        vm.deal(address(this), testAmount);
        vm.prank(address(this));
        fundManager.addFunds{value: testAmount}();
        assertEq(address(fundManager).balance, testAmount);
    }

    function testRequestWithdrawalEmitsEvent() public {
        vm.prank(fundManagerRole);
        vm.expectEmit(true, true, false, true);
        emit WithdrawalRequested(recipient, testAmount);
        fundManager.requestWithdrawal(recipient, testAmount);
    }

    function testApproveWithdrawalEmitsEvent() public {
        vm.prank(defaultAdmin);
        vm.expectEmit(true, true, false, true);
        emit WithdrawalApproved(recipient);
        fundManager.approveWithdrawal(recipient);
    }

    function testSendFundsEmitsEvent() public {
        vm.prank(defaultAdmin);
        fundManager.approveFundTransfer(recipient);
        
        vm.deal(address(fundManager), testAmount);
        vm.expectEmit(true, true, false, true);
        emit FundsSent(recipient, testAmount);

        vm.prank(fundManagerRole);
        fundManager.sendFunds(payable(recipient), testAmount);
    }

    //** EDGE CASES */

    function testZeroWithdrawalFails() public {
        vm.prank(fundManagerRole);
        vm.expectRevert("Invalid withdrawal amount");
        fundManager.withdrawFunds(payable(recipient), 0);
    }

    function testZeroTransferFails() public {
        vm.prank(fundManagerRole);
        vm.expectRevert("Invalid transfer amount");
        fundManager.sendFunds(payable(recipient), 0);
    }

    function testWithdrawLargeAmountFails() public {
        vm.prank(defaultAdmin);
        fundManager.approveWithdrawal(recipient);
        
        vm.deal(address(fundManager), testAmount);
        
        vm.prank(fundManagerRole);
        vm.expectRevert("Insufficient contract balance");
        fundManager.withdrawFunds(payable(recipient), testAmount * 2);
    }

    function testMultipleFundManagersCanWithdraw() public {
        vm.prank(defaultAdmin);
        adminContract.grantFundManager(secondFundManager);

        vm.prank(defaultAdmin);
        fundManager.approveWithdrawal(recipient);
        
        vm.deal(address(fundManager), testAmount);

        vm.prank(secondFundManager);
        fundManager.withdrawFunds(payable(recipient), testAmount);

        assertEq(address(fundManager).balance, 0);
    }

    function testReentrantWithdrawalBlocked() public {
        ReentrancyAttack attack = new ReentrancyAttack(fundManager);

        vm.prank(defaultAdmin);
        fundManager.approveWithdrawal(address(attack));

        vm.deal(address(fundManager), testAmount);

        vm.prank(address(attack));
        vm.expectRevert();
        attack.attackWithdraw();
    }

 function testRevertingRecipientFails() public {
    FaultyRecipient faultyRecipient = new FaultyRecipient();

    vm.prank(defaultAdmin);
    fundManager.approveFundTransfer(address(faultyRecipient));

    vm.deal(address(fundManager), testAmount);

    vm.prank(fundManagerRole);
    vm.expectRevert("Recipient contract rejects funds!");
    fundManager.sendFunds(payable(address(faultyRecipient)), testAmount);
}


// !! DOUBLE CHECK THIS
function testSimultaneousWithdrawalsHandledCorrectly() public {

    uint256 initialBalance = recipient.balance;

    vm.prank(defaultAdmin);
    fundManager.approveWithdrawal(recipient);

    vm.deal(address(fundManager), testAmount * 2);

    vm.prank(fundManagerRole);
    fundManager.withdrawFunds(payable(recipient), testAmount / 2);
 
    vm.prank(defaultAdmin);
    fundManager.approveWithdrawal(recipient);

    vm.prank(fundManagerRole);
    fundManager.withdrawFunds(payable(recipient), testAmount / 2);
 
    uint256 expectedBalance = initialBalance + testAmount;

    assertEq(recipient.balance, expectedBalance);

    uint256 fundManagerFinalBalance = address(fundManager).balance;
    
    assert(fundManagerFinalBalance >= 0);
}


}

// **Faulty Recipient Contract **
contract FaultyRecipient {
    receive() external payable {
        revert("Recipient contract rejects funds!");
    }
}


/// **Reentrancy Attack Contract **
contract ReentrancyAttack {
    FundManagerContract public fundManager;
    bool public attackStarted;

    constructor(FundManagerContract _fundManager) {
        fundManager = _fundManager;
    }

    receive() external payable {
        if (!attackStarted) {
            attackStarted = true;
            fundManager.withdrawFunds(payable(address(this)), 0.1 ether);
        }
    }

    function attackWithdraw() external {
        fundManager.withdrawFunds(payable(address(this)), 0.1 ether);
    }
}
