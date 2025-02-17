import Web3 from "web3";
import ENV from "../config/environment.mjs";
import abi from "../../abis/DEF_ADMIN_contract.json" assert { type: "json" };

// Connect to Web3
const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
const adminContract = new web3.eth.Contract(abi, ENV.contractAddresses.adminContract);

// Unlock the admin account
const account = web3.eth.accounts.privateKeyToAccount(ENV.privateKeyAnvil0);
web3.eth.accounts.wallet.add(account);
web3.eth.defaultAccount = account.address;

console.log(`✅ Using admin account: ${account.address}`);

// Role-Based Hierarchy
const ROLE_FUNCTION_MAPPING = {
    "PLATFORM_ADMIN_ROLE": "grantPlatformAdmin",
    "FUND_MANAGER_ROLE": "grantFundManager",
    "AUTHOR_ROLE": "grantAuthorRole",
};

// Assign Role
export const assignRole = async (role, address, sender) => {
    try {
        console.log(`📢 Assigning role: ${role} to ${address} from ${sender}`);

        const senderRoles = await getRolesForAddress(sender);
        console.log(`🔹 Sender has roles: ${senderRoles}`);

        let contractFunction;
        if (role === "PLATFORM_ADMIN_ROLE") contractFunction = "grantPlatformAdmin";
        else if (role === "FUND_MANAGER_ROLE") contractFunction = "grantFundManager";
        else if (role === "AUTHOR_ROLE") contractFunction = "grantAuthorRole";
        else throw new Error(`❌ Unknown role: ${role}`);

        if ((role === "PLATFORM_ADMIN_ROLE" || role === "FUND_MANAGER_ROLE") && !senderRoles.includes("DEFAULT_ADMIN_ROLE")) {
            throw new Error(`❌ Unauthorized: ${sender} cannot assign ${role}`);
        }

        if (role === "AUTHOR_ROLE" && !senderRoles.includes("PLATFORM_ADMIN_ROLE")) {
            throw new Error(`❌ Unauthorized: ${sender} cannot assign ${role}`);
        }

        const tx = await adminContract.methods[contractFunction](address).send({ from: sender });

        console.log(`✅ Role ${role} granted to ${address} in TX: ${tx.transactionHash}`);
        return { success: true, txHash: tx.transactionHash };
    } catch (error) {
        console.error("❌ Error assigning role:", error);
        throw new Error("Failed to assign role");
    }
};

// Revoke Role
export const revokeRole = async (role, address, sender) => {
    try {
        console.log(`📢 Revoking role: ${role} from ${address} by ${sender}`);

        const senderRoles = await getRolesForAddress(sender);
        console.log(`🔹 Sender has roles: ${senderRoles}`);

        let contractFunction;
        if (role === "PLATFORM_ADMIN_ROLE") contractFunction = "revokePlatformAdmin";
        else if (role === "FUND_MANAGER_ROLE") contractFunction = "revokeFundManager";
        else if (role === "AUTHOR_ROLE") contractFunction = "revokeAuthorRole";
        else throw new Error(`❌ Unknown role: ${role}`);

        if ((role === "PLATFORM_ADMIN_ROLE" || role === "FUND_MANAGER_ROLE") && !senderRoles.includes("DEFAULT_ADMIN_ROLE")) {
            throw new Error(`❌ Unauthorized: ${sender} cannot revoke ${role}`);
        }

        if (role === "AUTHOR_ROLE" && !senderRoles.includes("PLATFORM_ADMIN_ROLE")) {
            throw new Error(`❌ Unauthorized: ${sender} cannot revoke ${role}`);
        }

        const tx = await adminContract.methods[contractFunction](address).send({ from: sender });

        console.log(`✅ Role ${role} revoked from ${address} in TX: ${tx.transactionHash}`);
        return { success: true, txHash: tx.transactionHash };
    } catch (error) {
        console.error("❌ Error revoking role:", error);
        throw new Error("Failed to revoke role");
    }
};

// Get All Roles for an Address
export const getRolesForAddress = async (address) => {
    try {
        console.log(`📢 Fetching roles for ${address}`);
        const roles = [];

        const roleNames = ["DEFAULT_ADMIN_ROLE", "PLATFORM_ADMIN_ROLE", "FUND_MANAGER_ROLE", "AUTHOR_ROLE"];
        for (const role of roleNames) {
            const roleHash = web3.utils.keccak256(role);
            const hasRole = await adminContract.methods.hasSpecificRole(roleHash, address).call();
            if (hasRole) {
                roles.push(role);
            }
        }

        console.log(`✅ Roles for ${address}:`, roles); // 🔍 Log roles to debug
        return roles;
    } catch (error) {
        console.error("❌ Error getting roles:", error);
        throw new Error("Failed to get roles");
    }
};

// Get Platform Wallet
export const getPlatformWallet = async () => {
    try {
        console.log("📢 Fetching platform wallet...");
        const wallet = await adminContract.methods.getPlatformWallet().call();
        console.log(`✅ Platform Wallet: ${wallet}`);
        return wallet;
    } catch (error) {
        console.error("❌ Error fetching platform wallet:", error);
        throw new Error("Failed to get platform wallet");
    }
};

// Set Platform Wallet (Only DEFAULT_ADMIN_ROLE can call)
export const setPlatformWallet = async (newWallet, sender) => {
    try {
        console.log(`📢 Setting new platform wallet: ${newWallet} from ${sender}`);

        if (newWallet === "0x0000000000000000000000000000000000000000") {
            throw new Error("New wallet address cannot be zero");
        }

        const tx = await adminContract.methods.setPlatformWallet(newWallet).send({ from: sender });

        console.log(`✅ Platform wallet updated to ${newWallet} in TX: ${tx.transactionHash}`);
        return { success: true, txHash: tx.transactionHash };
    } catch (error) {
        console.error("❌ Error setting platform wallet:", error);
        throw new Error("Failed to set platform wallet");
    }
};
