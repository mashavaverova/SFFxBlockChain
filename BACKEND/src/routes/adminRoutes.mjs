import express from "express";
import { assignRole, 
    revokeRole, 
    getRolesForAddress, 
    getPlatformWallet, 
    setPlatformWallet } from "../services/adminService.mjs";

const router = express.Router();

// ✅ Assign Role
router.post("/assign-role", async (req, res) => {
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

// ✅ Revoke Role
router.post("/revoke-role", async (req, res) => {
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

// ✅ Get All Roles for an Address
router.get("/roles/:address", async (req, res) => {
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


// ✅ Get Current Platform Wallet
router.get('/platform-wallet', async (req, res) => {
    try {
        const wallet = await getPlatformWallet();
        res.json({ platformWallet: wallet });
    } catch (error) {
        console.error("❌ Error fetching platform wallet:", error);
        res.status(500).json({ error: "Failed to get platform wallet" });
    }
});

// ✅ Set New Platform Wallet
router.post('/set-platform-wallet', async (req, res) => {
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
