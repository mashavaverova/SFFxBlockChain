import express from "express";
import { assignRole, 
    revokeRole, 
    getRolesForAddress, 
    getPlatformWallet, 
    setPlatformWallet } from "../services/adminService.mjs";

import { authenticateToken, authorizeRole } from "../middlewares/authMiddleware.mjs";

const router = express.Router();

// Assign Role (Only DEFAULT_ADMIN or PLATFORM_ADMIN can assign roles)
router.post("/assign-role", authenticateToken, authorizeRole(['DEFAULT_ADMIN', 'PLATFORM_ADMIN']), async (req, res) => {
    try {
        const { role, address, sender } = req.body;

        if (!role || !address || !sender) {
            return res.status(400).json({ error: "Missing role, address, or sender" });
        }

        const result = await assignRole(role, address, sender);
        res.json(result);
    } catch (error) {
        console.error("❌ Error in assign-role:", error.message);
        res.status(500).json({ error: error.message });
    }
});

// Revoke Role (Only DEFAULT_ADMIN or PLATFORM_ADMIN can revoke roles)
router.post("/revoke-role", authenticateToken, authorizeRole(['DEFAULT_ADMIN', 'PLATFORM_ADMIN']), async (req, res) => {
    try {
        const { role, address, sender } = req.body;

        if (!role || !address || !sender) {
            return res.status(400).json({ error: "Missing role, address, or sender" });
        }

        const result = await revokeRole(role, address, sender);
        res.json(result);
    } catch (error) {
        console.error("❌ Error in revoke-role:", error.message);
        res.status(500).json({ error: error.message });
    }
});

// Get All Roles for an Address (Only admins can view roles)
router.get("/roles/:address", authenticateToken, authorizeRole(['DEFAULT_ADMIN', 'PLATFORM_ADMIN']), async (req, res) => {
    try {
        const { address } = req.params;

        if (!address) {
            return res.status(400).json({ error: "Missing address" });
        }

        const roles = await getRolesForAddress(address);
        res.json({ address, roles });
    } catch (error) {
        console.error("❌ Error in getRolesForAddress:", error.message);
        res.status(500).json({ error: "Failed to get roles" });
    }
});

// Get Current Platform Wallet (Only DEFAULT_ADMIN and PLATFORM_ADMIN can see it)
router.get('/platform-wallet', authenticateToken, authorizeRole(['DEFAULT_ADMIN', 'PLATFORM_ADMIN']), async (req, res) => {
    try {
        const wallet = await getPlatformWallet();
        res.json({ platformWallet: wallet });
    } catch (error) {
        console.error("❌ Error fetching platform wallet:", error);
        res.status(500).json({ error: "Failed to get platform wallet" });
    }
});

// Set New Platform Wallet (Only DEFAULT_ADMIN can change it)
router.post('/set-platform-wallet', authenticateToken, authorizeRole(['DEFAULT_ADMIN']), async (req, res) => {
    try {
        const { newWallet, sender } = req.body;
        if (!newWallet || !sender) {
            return res.status(400).json({ error: "Missing newWallet or sender" });
        }

        const result = await setPlatformWallet(newWallet, sender);
        res.json(result);
    } catch (error) {
        console.error("❌ Error setting platform wallet:", error);
        res.status(500).json({ error: "Failed to set platform wallet" });
    }
});

export default router;
