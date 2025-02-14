import fs from 'fs';
import path from 'path';
import { ethers } from 'ethers';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables

// Read ABIs dynamically
const loadABI = (name) => {
    const abiPath = path.resolve('abis', `${name}.json`);
    return JSON.parse(fs.readFileSync(abiPath, 'utf-8'));
};

// Setup provider
const provider = new ethers.JsonRpcProvider(process.env.ANVIL_RPC_URL);

// Setup wallet
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY_ANVIL_0, provider);

// Load deployed contract instances
const contracts = {
    admin: new ethers.Contract(process.env.ADMIN_CONTRACT, loadABI('AdminContract'), wallet),
    fundManager: new ethers.Contract(process.env.FUND_MANAGER_CONTRACT, loadABI('FundManagerContract'), wallet),
    paymentSplitter: new ethers.Contract(process.env.PAYMENT_SPLITTER_CONTRACT, loadABI('PaymentSplitterContract'), wallet),
    marketplace: new ethers.Contract(process.env.MARKETPLACE_CONTRACT, loadABI('MarketplaceContract'), wallet),
    rightsManager: new ethers.Contract(process.env.RIGHTS_MANAGER_CONTRACT, loadABI('RightsManagerContract'), wallet),
    nftBook: new ethers.Contract(process.env.NFTBOOK_CONTRACT, loadABI('NFTBookContract'), wallet)
};

export default contracts;
