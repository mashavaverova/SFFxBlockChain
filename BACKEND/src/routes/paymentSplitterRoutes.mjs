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

import { authenticateToken, authorizeRole } from "../middlewares/authMiddleware.mjs";

const router = express.Router();

// Platform Fee Management (Only Platform Admins)
router.post("/set-platform-fee", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), setPlatformFee);
router.get("/get-platform-fee/:author", authenticateToken, getPlatformFee); // Public Access: Anyone can check

// Author Revenue Split Management (Only Authors & Platform Admins)
router.post("/set-author-splits", authenticateToken, authorizeRole(['AUTHOR', 'PLATFORM_ADMIN']), setAuthorSplits);
router.post("/delete-author-splits", authenticateToken, authorizeRole(['AUTHOR', 'PLATFORM_ADMIN']), deleteAuthorSplits);
router.get("/recipients/:author", authenticateToken, getRecipients); // Public: Anyone can see recipients
router.get("/percentages/:author", authenticateToken, getPercentages); // Public: Anyone can see percentages

router.post("/split-payment", splitPayment);
router.post("/claim-failed-payments", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), claimFailedPayments);

export default router;
