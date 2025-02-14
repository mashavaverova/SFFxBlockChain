import Web3 from 'web3';
import { ENV } from '../config/environment.mjs';

// Validate ENV variables
if (!ENV.anvilRpcUrl) {
    console.error('❌ ANVIL_RPC_URL is missing in the .env file.');
    process.exit(1);
}
if (!ENV.privateKeyAnvil0) {
    console.error('❌ PRIVATE_KEY_ANVIL_0 is missing in the .env file.');
    process.exit(1);
}

// Initialize Web3 with the RPC URL
const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
console.log('✅ Connected to RPC:', ENV.anvilRpcUrl);

// Extract account from private key
const account = web3.eth.accounts.privateKeyToAccount(ENV.privateKeyAnvil0.toLowerCase());

// Check if the account is already in the wallet
if (!web3.eth.accounts.wallet[account.address]) {
    web3.eth.accounts.wallet.add(account);
    console.log(`✅ Account added to Web3 wallet: ${account.address}`);
} else {
    console.log(`⚡ Account ${account.address} already exists in the Web3 wallet.`);
}

// Export Web3 instance
export default web3;
