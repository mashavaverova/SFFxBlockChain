import dotenv from 'dotenv';
dotenv.config();

export const ENV = {
    port: process.env.PORT || 3000,
    alchemyApiUrl: process.env.AlCHEMY_API_URL,
    anvilRpcUrl: process.env.ANVIL_RPC_URL,
    privateKeyAnvil0: process.env.PRIVATE_KEY_ANVIL_0,
    jwtSecret: process.env.JWT_SECRET,
    refreshTokenSecret: process.env.REFRESH_TOKEN_SECRET,
    mongoUri: process.env.MONGO_URI || 'mongodb://localhost:27017/libretyverse',
    defaultAdminWallet: process.env.DEFAULT_ADMIN_WALLET || '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266',

    contractAddresses: {
        adminContract: process.env.ADMIN_CONTRACT,
        fundManagerContract: process.env.FUND_MANAGER_CONTRACT,
        paymentSplitterContract: process.env.PAYMENT_SPLITTER_CONTRACT,
        marketplaceContract: process.env.MARKETPLACE_CONTRACT,
        rightsManagerContract: process.env.RIGHTS_MANAGER_CONTRACT,
        nftBookContract: process.env.NFTBOOK_CONTRACT,
    },
};

console.log('Loaded Environment Variables:');
console.log('Alchemy API URL:', ENV.alchemyApiUrl);
console.log('Anvil RPC URL:', ENV.anvilRpcUrl);
console.log('Private Key (Anvil 0):', ENV.privateKeyAnvil0 ? 'Loaded' : 'Not Found');
console.log('MongoDB URI:', ENV.mongoUri);
console.log('Contract Addresses:', ENV.contractAddresses);

export default ENV;
