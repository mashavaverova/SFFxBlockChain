import express from "express";
import {
    listToken,
    updateListing,
    removeListing,
    getListing,
    purchaseToken
} from "../services/marketplaceService.mjs";

const router = express.Router();

// 📌 Token Listings
router.post("/list", listToken);
router.post("/update", updateListing);
router.delete("/remove", removeListing);
router.get("/:tokenId", getListing);

// 🔥 Purchase Token
router.post("/purchase", purchaseToken);

export default router;
