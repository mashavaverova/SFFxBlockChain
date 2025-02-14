import express from "express";
import {
    setPlatformFee,
    setAuthorSplits,
    deleteAuthorSplits,
    splitPayment,
    getPlatformFee,
    getRecipients,
    getPercentages,
    claimFailedPayments
} from "../services/paymentSplitterService.mjs";

const router = express.Router();

// 💰 Platform Fee Management
router.post("/set-platform-fee", setPlatformFee);
router.get("/get-platform-fee/:author", getPlatformFee);

// 📖 Author Revenue Split Management
router.post("/set-author-splits", setAuthorSplits);
router.post("/delete-author-splits", deleteAuthorSplits);
router.get("/recipients/:author", getRecipients);
router.get("/percentages/:author", getPercentages);

// 💵 Payment & Distribution
router.post("/split-payment", splitPayment);
router.post("/claim-failed-payments", claimFailedPayments);

export default router;
