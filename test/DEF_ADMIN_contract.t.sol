// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "forge-std/Test.sol";
import "../src/DEF_ADMIN_contract.sol";

contract DEF_ADMIN_contract_test is Test {
    DEF_ADMIN_contract public adminContract;
    address public defaultAdmin = address(0x1);
    address public platformAdmin = address(0x2);
    address public fundManager = address(0x3);
    address public author = address(0x4);
    address public unauthorized = address(0x5);
    address public defaultPlatformWallet = address(0x6);
    

    bytes32 public constant PLATFORM_ADMIN_ROLE = keccak256("PLATFORM_ADMIN_ROLE");
    bytes32 public constant FUND_MANAGER_ROLE = keccak256("FUND_MANAGER_ROLE");
    bytes32 public constant AUTHOR_ROLE = keccak256("AUTHOR_ROLE");

    function setUp() public {
        vm.prank(defaultAdmin);
        adminContract = new DEF_ADMIN_contract(defaultAdmin, payable(defaultPlatformWallet));
    }

    //** UNIT TESTS */
    function testDefaultAdminRole() public view {
        assertTrue(adminContract.hasRole(adminContract.DEFAULT_ADMIN_ROLE(), defaultAdmin));
    }

    function testGrantPlatformAdminEmitsEvent() public {
        vm.prank(defaultAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.PlatformAdminGranted(platformAdmin, defaultAdmin);

        adminContract.grantPlatformAdmin(platformAdmin);
    }

    function testRevokePlatformAdminEmitsEvent() public {
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.prank(defaultAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.PlatformAdminRevoked(platformAdmin, defaultAdmin);

        adminContract.revokePlatformAdmin(platformAdmin);
    }

    function testGrantFundManagerEmitsEvent() public {
        vm.prank(defaultAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.FundManagerGranted(fundManager, defaultAdmin);

        adminContract.grantFundManager(fundManager);
    }

    function testRevokeFundManagerEmitsEvent() public {
        vm.prank(defaultAdmin);
        adminContract.grantFundManager(fundManager);

        vm.prank(defaultAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.FundManagerRevoked(fundManager, defaultAdmin);

        adminContract.revokeFundManager(fundManager);
    }

    function testGrantAuthorEmitsEvent() public {
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.prank(platformAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.AuthorGranted(author, platformAdmin);

        adminContract.grantAuthorRole(author);
    }

    function testRevokeAuthorEmitsEvent() public {
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.prank(platformAdmin);
        adminContract.grantAuthorRole(author);

        vm.prank(platformAdmin);

        vm.expectEmit(true, true, false, true);
        emit DEF_ADMIN_contract.AuthorRevoked(author, platformAdmin);

        adminContract.revokeAuthorRole(author);
    }

    function testUnauthorizedGrantFails() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, unauthorized, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(unauthorized);
        adminContract.grantPlatformAdmin(platformAdmin);
    }

    function testUnauthorizedRevokeFails() public {
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, unauthorized, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(unauthorized);
        adminContract.revokePlatformAdmin(platformAdmin);
    }

    //** EDGE CASES  */
    function testGrantRoleToZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(DEF_ADMIN_contract.InvalidAddress.selector, address(0)));
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(address(0));
    }

    function testRevokeRoleFromZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(DEF_ADMIN_contract.InvalidAddress.selector, address(0)));
        vm.prank(defaultAdmin);
        adminContract.revokePlatformAdmin(address(0));
    }

    function testRegrantRole() public {
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);
        assertTrue(adminContract.hasRole(PLATFORM_ADMIN_ROLE, platformAdmin));

        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(platformAdmin);
        assertTrue(adminContract.hasRole(PLATFORM_ADMIN_ROLE, platformAdmin)); // No change
    }

    function testRevokeUnassignedRole() public {
        vm.prank(defaultAdmin);
        adminContract.revokePlatformAdmin(platformAdmin); // No revert expected
        assertFalse(adminContract.hasRole(PLATFORM_ADMIN_ROLE, platformAdmin));
    }

    // ** FUZZ TESTS */
    function testFuzzGrantAndRevokePlatformAdmin(address randomAddress) public {
        // Ensure randomAddress is not zero
        vm.assume(randomAddress != address(0));

        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(randomAddress);
        assertTrue(adminContract.hasRole(PLATFORM_ADMIN_ROLE, randomAddress));

        vm.prank(defaultAdmin);
        adminContract.revokePlatformAdmin(randomAddress);
        assertFalse(adminContract.hasRole(PLATFORM_ADMIN_ROLE, randomAddress));
    }

    function testFuzzUnauthorizedActions(address randomAddress) public {
        vm.assume(randomAddress != address(0) && randomAddress != defaultAdmin);

        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, randomAddress, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(randomAddress);
        adminContract.grantPlatformAdmin(platformAdmin);

        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, randomAddress, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(randomAddress);
        adminContract.revokePlatformAdmin(platformAdmin);
    }

    function testFuzzUnauthorizedRoleManagement(address randomAddress1, address randomAddress2) public {
        vm.assume(randomAddress1 != address(0) && randomAddress2 != address(0));
        vm.assume(randomAddress1 != defaultAdmin);

        // Unauthorized grant
        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, randomAddress1, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(randomAddress1);
        adminContract.grantPlatformAdmin(randomAddress2);

        // Unauthorized revoke
        vm.expectRevert(
            abi.encodeWithSelector(
                DEF_ADMIN_contract.Unauthorized.selector, randomAddress1, adminContract.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(randomAddress1);
        adminContract.revokePlatformAdmin(randomAddress2);
    }

    function testFuzzInvalidAddresses(address randomAddress) public {
        vm.assume(randomAddress != address(0));

        // Grant role to random address
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(randomAddress);

        // Attempt to grant role to address(0)
        vm.expectRevert(abi.encodeWithSelector(DEF_ADMIN_contract.InvalidAddress.selector, address(0)));
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(address(0));

        // Attempt to revoke role from address(0)
        vm.expectRevert(abi.encodeWithSelector(DEF_ADMIN_contract.InvalidAddress.selector, address(0)));
        vm.prank(defaultAdmin);
        adminContract.revokePlatformAdmin(address(0));
    }

    function testFuzzMultipleRoleAssignments(address randomAddress1, address randomAddress2) public {
        // Ensure addresses are not zero
        vm.assume(randomAddress1 != address(0) && randomAddress2 != address(0));
        vm.assume(randomAddress1 != randomAddress2);

        // Grant the first role
        vm.prank(defaultAdmin);
        adminContract.grantPlatformAdmin(randomAddress1);
        assertTrue(adminContract.hasRole(PLATFORM_ADMIN_ROLE, randomAddress1));

        // Grant the second role
        vm.prank(defaultAdmin);
        adminContract.grantFundManager(randomAddress2);
        assertTrue(adminContract.hasRole(FUND_MANAGER_ROLE, randomAddress2));

        // Attempt to revoke the roles
        vm.prank(defaultAdmin);
        adminContract.revokePlatformAdmin(randomAddress1);
        assertFalse(adminContract.hasRole(PLATFORM_ADMIN_ROLE, randomAddress1));

        vm.prank(defaultAdmin);
        adminContract.revokeFundManager(randomAddress2);
        assertFalse(adminContract.hasRole(FUND_MANAGER_ROLE, randomAddress2));
    }
}
