import Web3 from "web3";
import ENV from "../config/environment.mjs";
import abi from "../../abis/PaymentSplitterContract.json" assert { type: "json" };
import { convertBigInt } from "../utils/convertBigInt.mjs";

// Connect Web3
const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
const paymentSplitterContractAddress = ENV.contractAddresses.paymentSplitterContract;
const contract = new web3.eth.Contract(abi, paymentSplitterContractAddress);

console.log("🔍 PaymentSplitter Address:", paymentSplitterContractAddress);
console.log("🔍 Contract Instance:", paymentSplitterContractAddress);

// Utility Function to Handle EIP-1559 Gas
async function getGasConfig() {
    const baseGasPrice = await web3.eth.getGasPrice();
    return {
        maxPriorityFeePerGas: BigInt(baseGasPrice) / BigInt(2),
        maxFeePerGas: BigInt(baseGasPrice) * BigInt(2),
    };
}

// Set Platform Fee
async function setPlatformFee(req, res, next) {
    try {
        const { author, fee, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.setPlatformFee(author, fee);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: paymentSplitterContractAddress,
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
// Set Author Split Config
async function setAuthorSplits(req, res, next) {
    try {
        const { author, recipients, percentages, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.setAuthorSplits(author, recipients, percentages);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: paymentSplitterContractAddress,
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

// Delete Author Split Config
async function deleteAuthorSplits(req, res, next) {
    try {
        const { author, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.deleteAuthorSplits(author);
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: paymentSplitterContractAddress,
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

// Split Payment
async function splitPayment(req, res, next) {
    try {
        const { author, amount, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.splitPayment(author);
        const gas = await tx.estimateGas({ from: account.address, value: amount });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: paymentSplitterContractAddress,
                data: tx.encodeABI(),
                gas,
                ...gasConfig,
                from: account.address,
                value: amount,
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

// Get Platform Fee
async function getPlatformFee(req, res, next) {
    try {
        const author = req.params.author;
        const platformFee = await contract.methods.getPlatformFee(author).call();
        res.json({ success: true, platformFee: convertBigInt(platformFee) });
    } catch (error) {
        next(error);
    }
}

// Get Recipients
async function getRecipients(req, res, next) {
    try {
        const author = req.params.author;

        // ✅ Fetch raw recipients data
        let recipients = await contract.methods.getRecipients(author).call();

        // ✅ Ensure proper formatting (removes empty bytes)
        recipients = recipients.filter(address => address !== "0x0000000000000000000000000000000000000000");

        console.log("📢 Decoded Recipients:", recipients); // 🔍 Debug

        res.json({ success: true, recipients });
    } catch (error) {
        next(error);
    }
}

// Get Percentages
async function getPercentages(req, res, next) {
    try {
        const author = req.params.author;
        const percentages = await contract.methods.getPercentages(author).call();
        res.json({ success: true, percentages: convertBigInt(percentages) });
    } catch (error) {
        next(error);
    }
}

// Claim Failed Payments
async function claimFailedPayments(req, res, next) {
    try {
        const { privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.claimFailedPayments();
        const gas = await tx.estimateGas({ from: account.address });
        const gasConfig = await getGasConfig();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: paymentSplitterContractAddress,
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

export {
    setPlatformFee,
    setAuthorSplits,
    deleteAuthorSplits,
    splitPayment,
    getPlatformFee,
    getRecipients,
    getPercentages,
    claimFailedPayments
};
