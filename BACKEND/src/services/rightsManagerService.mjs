import Web3 from "web3";
import ENV from "../config/environment.mjs";
import abi from "../../abis/RightsManagerContract.json" assert { type: "json" };
import { convertBigInt } from "../utils/convertBigInt.mjs";

// ✅ Connect Web3
const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
const rightsManagerContractAddress = ENV.contractAddresses.rightsManagerContract;
const contract = new web3.eth.Contract(abi, rightsManagerContractAddress);

console.log("🔍 RightsManager Address:", rightsManagerContractAddress);

// ✅ Utility Function to Handle EIP-1559 Gas
async function getGasConfig() {
    const baseGasPrice = await web3.eth.getGasPrice();
    return {
        maxPriorityFeePerGas: BigInt(baseGasPrice) / BigInt(2),
        maxFeePerGas: BigInt(baseGasPrice) * BigInt(2),
    };
}

// ✅ 1️⃣ Set Marketplace
async function setMarketplace(req, res, next) {
    try {
        const { newMarketplace, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.setMarketplace(newMarketplace);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: rightsManagerContractAddress,
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

// ✅ 2️⃣ Initiate Rights Request
async function initiateRequest(req, res, next) {
    try {
        const { tokenId, requestDate, buyer, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.initiateRequest(tokenId, requestDate, buyer);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: rightsManagerContractAddress,
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

// ✅ 3️⃣ Author Approval
async function authorApprove(req, res, next) {
    try {
        const { tokenId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.authorApprove(tokenId);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: rightsManagerContractAddress,
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

// ✅ 4️⃣ Complete Rights Transfer
async function completeTransfer(req, res, next) {
    try {
        const { tokenId, expirationDate, ipfsHash, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.completeTransfer(tokenId, expirationDate, ipfsHash);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: rightsManagerContractAddress,
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

// ✅ 5️⃣ Get Rights Info
async function getRightsInfo(req, res, next) {
    try {
        const tokenId = req.params.tokenId;
        const rightsInfo = await contract.methods.getRightsInfo(tokenId).call();
        res.json({ success: true, rightsInfo: convertBigInt(rightsInfo) });
    } catch (error) {
        next(error);
    }
}

export {
    setMarketplace,
    initiateRequest,
    authorApprove,
    completeTransfer,
    getRightsInfo
};

