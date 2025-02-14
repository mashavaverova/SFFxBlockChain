import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { connectDB } from './config/db.mjs';
import adminRoutes from './routes/adminRoutes.mjs';
import bookRoutes from './routes/bookRoutes.mjs';
import paymentSplitterRoutes from "./routes/paymentSplitterRoutes.mjs";
import marketplaceRoutes from "./routes/marketplaceRoutes.mjs";
import rightsManagerRoutes from "./routes/rightsManagerRoutes.mjs";



// Load environment variables
dotenv.config();

// Initialize Express App
const app = express();

// ✅ Database Connection
(async () => {
    await connectDB();
})();

// ✅ Middleware
app.use(express.json());
app.use(cors());

// ✅ Logging & Debugging
console.log("✅ Server is initializing...");

// ✅ Load Routes
console.log("✅ Loading admin routes...");
app.use("/admin", adminRoutes);

console.log("✅ Loading book routes...");
app.use("/book", bookRoutes);

console.log("✅ Loading Payment Splitter Routes...");
app.use("/payment-splitter", paymentSplitterRoutes);

// ✅ Load Marketplace Routes
console.log("✅ Loading Marketplace Routes...");
app.use("/marketplace", marketplaceRoutes);

console.log("✅ Loading Rights Manager Routes...");
app.use("/rights-manager", rightsManagerRoutes);




// ✅ Health Check Route
app.get('/', (req, res) => {
    console.log("✅ Default route accessed");
    res.send("✅ Backend API is Running!");
});

// ✅ Centralized Error Handling
app.use((err, req, res, next) => {
    console.error("❌ Error:", err.message);
    res.status(500).json({ error: err.message });
});

// ✅ 404 - Route Not Found
app.use((req, res) => {
    console.log(`❌ Route not found: ${req.method} ${req.originalUrl}`);
    res.status(404).json({ error: 'Route not found' });
});

// ✅ Graceful Shutdown
const shutdown = async () => {
    console.log('🔴 Shutting down server...');
    process.exit(0);
};

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

export default app;
