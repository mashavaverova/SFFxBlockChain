import Web3 from "web3";
import ENV from "../config/environment.mjs";
import abi from "../../abis/NFTBookContract.json" assert { type: "json" };
import { convertBigInt } from "../utils/convertBigInt.mjs";

const web3 = new Web3(new Web3.providers.HttpProvider(ENV.anvilRpcUrl));
const nftBookContractAddress = ENV.contractAddresses.nftBookContract;
const contract = new web3.eth.Contract(abi, nftBookContractAddress);

async function requestPublishBook(req, res, next) {
    try {
        const { recipient, title, bookHash, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.requestPublishBook(recipient, title, bookHash);
        const gas = await tx.estimateGas({ from: account.address });
        const gasPrice = await web3.eth.getGasPrice();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: nftBookContractAddress,
                data: tx.encodeABI(),
                gas,
                gasPrice,
                from: account.address
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

        // Convert entire receipt
        res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

async function approvePublishing(req, res, next) {
    try {
        const { requestId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);
        
        const tx = contract.methods.approvePublishing(requestId);
        const gas = await tx.estimateGas({ from: account.address });

        // Get EIP-1559 gas values
        const feeHistory = await web3.eth.getFeeHistory(1, "latest", [25, 50, 75]);
        const maxPriorityFeePerGas = feeHistory.reward[0][2] || "2000000000";  // Default 2 gwei
        const maxFeePerGas = (parseInt(await web3.eth.getGasPrice()) + parseInt(maxPriorityFeePerGas)).toString();

        const signedTx = await web3.eth.accounts.signTransaction(
            {
                to: nftBookContractAddress,
                data: tx.encodeABI(),
                gas,
                maxPriorityFeePerGas, // ✅ Use EIP-1559 gas params
                maxFeePerGas,
                from: account.address
            },
            privateKey
        );

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

        // ✅ Convert BigInt values before returning the response
        res.json({ success: true, receipt: convertBigInt(receipt) });

    } catch (error) {
        next(error);
    }
}



async function publishDirect(req, res, next) {
    try {
        const { recipient, title, bookHash, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.publishForUnregistered(recipient, title, bookHash);
        const gas = await tx.estimateGas({ from: account.address });

        const signedTx = await account.signTransaction({
            to: nftBookContractAddress,
            data: tx.encodeABI(),
            gas,
            from: account.address
        }, privateKey);

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

async function getBookMetadata(req, res, next) {
    try {
        const tokenId = req.params.tokenId;
        const metadata = await contract.methods.bookMetadata(tokenId).call();
        
        res.json({ success: true, metadata: convertBigInt(metadata) });
    } catch (error) {
        next(error);
    }
}


async function getOwner(req, res, next) {
    try {
        const tokenId = req.params.tokenId;
        const owner = await contract.methods.ownerOf(tokenId).call();
        
        res.json({ success: true, owner: convertBigInt(owner) });  // ✅ Apply conversion here
    } catch (error) {
        next(error);
    }
}




    async function requestDeleteBook(req, res, next) {
        try {
            const tokenId = req.params.tokenId;
            const { privateKey } = req.body;

            const account = web3.eth.accounts.privateKeyToAccount(privateKey);
            
            const tx = contract.methods.requestDeleteBook(tokenId);
            const gas = await tx.estimateGas({ from: account.address });
    const baseGasPrice = await web3.eth.getGasPrice();  // Fetch network gas price

    const maxPriorityFeePerGas = BigInt(baseGasPrice) / BigInt(2); // 50% of base gas price
    const maxFeePerGas = BigInt(baseGasPrice) * BigInt(2); // 2x base gas price (Ensures it's higher)

    const signedTx = await account.signTransaction({
        to: nftBookContractAddress,
        data: tx.encodeABI(),
        gas,
        maxPriorityFeePerGas,
        maxFeePerGas,
        from: account.address
    }, privateKey);

    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    res.json({ success: true, receipt: convertBigInt(receipt) });

        
        } catch (error) {
            next(error);}
    }

async function approveDeletion(req, res, next) {
    try {
        const { requestId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);
        
        const tx = contract.methods.approveDeletion(requestId);
        const gas = await tx.estimateGas({ from: account.address });

        const signedTx = await account.signTransaction({
            to: nftBookContractAddress,
            data: tx.encodeABI(),
            gas,
            from: account.address
        }, privateKey);

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

async function deleteDirect(req, res, next) {
    try {
        const { tokenId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.deleteForUnregistered(tokenId);
        const gas = await tx.estimateGas({ from: account.address });

        const signedTx = await account.signTransaction({
            to: nftBookContractAddress,
            data: tx.encodeABI(),
            gas,
            from: account.address
        }, privateKey);

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

async function markAsPurchased(req, res, next) {
    try {
        const { tokenId, privateKey } = req.body;
        const account = web3.eth.accounts.privateKeyToAccount(privateKey);

        const tx = contract.methods.markAsPurchased(tokenId);
        const gas = await tx.estimateGas({ from: account.address });

        const signedTx = await account.signTransaction({
            to: nftBookContractAddress,
            data: tx.encodeABI(),
            gas,
            from: account.address
        }, privateKey);

        const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
res.json({ success: true, receipt: convertBigInt(receipt) });
    } catch (error) {
        next(error);
    }
}

export { 
    requestPublishBook, 
    approvePublishing, 
    publishDirect, 
    getBookMetadata, 
    getOwner, 
    requestDeleteBook, 
    approveDeletion, 
    deleteDirect, 
    markAsPurchased 
};
