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

const router = express.Router();

// 📚 1️⃣ Publishing & Approving
router.post("/request", requestPublishBook);
router.post("/approve/:requestId", approvePublishing);
router.post("/publish-direct", publishDirect);

// 🔍 2️⃣ Get Metadata & Owner
router.get("/:tokenId", getBookMetadata);
router.get("/owner/:tokenId", getOwner);

// 🗑 3️⃣ Deleting Books
router.post("/request-delete/:tokenId", requestDeleteBook);
router.post("/approve-delete/:requestId", approveDeletion);
router.post("/delete-direct/:tokenId", deleteDirect);

// 🔄 4️⃣ Purchasing & Transfers
router.post("/mark-purchased/:tokenId", markAsPurchased);


export default router;
