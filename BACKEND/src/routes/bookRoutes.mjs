import express from "express";
import { requestPublishBook,
     approvePublishing, 
     publishDirect, 
     getBookMetadata, 
     getOwner, 
     requestDeleteBook, 
     approveDeletion, 
     deleteDirect, 
     markAsPurchased } from "../services/bookService.mjs";

import { authenticateToken, authorizeRole } from "../middlewares/authMiddleware.mjs";

const router = express.Router();

// Publishing & Approving
router.post("/request", authenticateToken, authorizeRole(['AUTHOR']), requestPublishBook);
router.post("/approve/:requestId", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), approvePublishing);
router.post("/publish-direct", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), publishDirect);

// Get Metadata & Owner (Accessible to all, even unauthenticated users)
router.get("/:tokenId", getBookMetadata);
router.get("/owner/:tokenId", getOwner);

// Deleting Books
router.post("/request-delete/:tokenId", authenticateToken, authorizeRole(['AUTHOR']), requestDeleteBook);
router.post("/approve-delete/:requestId", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), approveDeletion);
router.post("/delete-direct/:tokenId", authenticateToken, authorizeRole(['PLATFORM_ADMIN']), deleteDirect);

// Purchasing & Transfers
router.post("/mark-purchased/:tokenId", markAsPurchased);

export default router;
