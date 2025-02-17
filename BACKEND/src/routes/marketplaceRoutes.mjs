import express from "express";
import {
    listToken,
    updateListing,
    removeListing,
    getListing,
    purchaseToken
} from "../services/marketplaceService.mjs";

import { authenticateToken, authorizeRole } from "../middlewares/authMiddleware.mjs";

const router = express.Router();

// Token Listings (Only Authors can list, Only Platform Admins can update/remove)
router.post("/list", authenticateToken, authorizeRole(['PLATFORM_ADMIN','AUTHOR']), listToken);
router.post("/update", authenticateToken, authorizeRole(['PLATFORM_ADMIN', 'AUTHOR']), updateListing);
router.delete("/remove", authenticateToken, authorizeRole(['PLATFORM_ADMIN', 'AUTHOR']), removeListing);
router.get("/:tokenId", getListing); // Public Access: Anyone can view listings

// Purchase Token (Only Buyers)
router.post("/purchase", authenticateToken, authorizeRole(['BUYER']), purchaseToken);

export default router;
