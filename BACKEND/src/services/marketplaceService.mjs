import Web3 from "web3";
import ENV from "../config/environment.mjs";
import abi from "../../abis/MarketplaceContract.json" assert { type: "json" };
import { convertBigInt } from "../utils/convertBigInt.mjs";

// ✅ Connect Web3
const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
const marketplaceContractAddress = ENV.contractAddresses.marketplaceContract;
const contract = new web3.eth.Contract(abi, marketplaceContractAddress);

console.log("🔍 Marketplace Address:", marketplaceContractAddress);

// ✅ Utility Function to Handle EIP-1559 Gas
async function getGasConfig() {
    const baseGasPrice = await web3.eth.getGasPrice();
    return {
        maxPriorityFeePerGas: BigInt(baseGasPrice) / BigInt(2),
        maxFeePerGas: BigInt(baseGasPrice) * BigInt(2),
    };
}

// ✅ 1️⃣ List Token for Sale
async function listToken(req, res, next) {
    try {
        const { tokenId, price, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.listToken(tokenId, price);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: marketplaceContractAddress,
                data: tx.encodeABI(),
                gas,
                ...gasConfig,
                from: account.address,
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

// ✅ 2️⃣ Update Listing Price
async function updateListing(req, res, next) {
    try {
        const { tokenId, newPrice, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.updateListing(tokenId, newPrice);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: marketplaceContractAddress,
                data: tx.encodeABI(),
                gas,
                ...gasConfig,
                from: account.address,
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

// ✅ 3️⃣ Remove Listing
async function removeListing(req, res, next) {
    try {
        const { tokenId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.removeListing(tokenId);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: marketplaceContractAddress,
                data: tx.encodeABI(),
                gas,
                ...gasConfig,
                from: account.address,
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

// ✅ 4️⃣ Get Listing Details
async function getListing(req, res, next) {
    try {
        const tokenId = req.params.tokenId;
        const listing = await contract.methods.getListing(tokenId).call();
        res.json({ success: true, listing: convertBigInt(listing) });
    } catch (error) {
        next(error);
    }
}

// ✅ 5️⃣ Purchase Token (Transfers Ownership & Rights)
async function purchaseToken(req, res, next) {
    try {
        const { tokenId, privateKey, value } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.purchaseToken(tokenId);
        const gas = await tx.estimateGas({ from: account.address, value });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: marketplaceContractAddress,
                data: tx.encodeABI(),
                gas,
                ...gasConfig,
                from: account.address,
                value, // Amount sent for purchase
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

export {
    listToken,
    updateListing,
    removeListing,
    getListing,
    purchaseToken,
};
