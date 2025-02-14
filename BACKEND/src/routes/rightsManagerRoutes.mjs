import express from "express";
import {
    setMarketplace,
    initiateRequest,
    authorApprove,
    completeTransfer,
    getRightsInfo
} from "../services/rightsManagerService.mjs";

const router = express.Router();

// 🔹 Platform Admin Function
router.post("/set-marketplace", setMarketplace);

// 🔹 Rights Request Functions
router.post("/initiate-request", initiateRequest);
router.post("/author-approve", authorApprove);
router.post("/complete-transfer", completeTransfer);

// 🔹 Query Functions
router.get("/rights-info/:tokenId", getRightsInfo);

export default router;
