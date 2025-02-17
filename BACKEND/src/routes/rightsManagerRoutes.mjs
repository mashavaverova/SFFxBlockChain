import express from "express";
import {
    setMarketplace,
    initiateRequest,
    authorApprove,
    completeTransfer,
    getRightsInfo
} from "../services/rightsManagerService.mjs";

import { authenticateToken, authorizeRole } from "../middlewares/authMiddleware.mjs";

const router = express.Router();

// Platform Admin Function (Only Platform Admin)
router.post("/set-marketplace", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), setMarketplace);

// Rights Request Functions
router.post("/initiate-request", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), initiateRequest); // Only Platform Admin can initiate
router.post("/author-approve", authenticateToken, authorizeRole(['AUTHOR']), authorApprove); // Only Authors can approve
router.post("/complete-transfer", authenticateToken, authorizeRole(['PLATFORM_ADMIN', 'FUND_MANAGER']), completeTransfer); // Fund Managers or Platform Admins complete transfers

// Query Functions (Anyone Can View Rights Info)
router.get("/rights-info/:tokenId", getRightsInfo); // Public Access: Anyone can query rights info

export default router;
