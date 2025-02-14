import app from './src/app.mjs'; 
import { ENV } from './src/config/environment.mjs'; 
import { connectDB } from './src/config/db.mjs';

(async () => {
    await connectDB();
    console.log('✅ Connected to MongoDB');

    const PORT = ENV.port || 3000;
    console.log(`🟢 Attempting to start server on port: ${PORT}`);

    app.listen(PORT, () => {
        console.log(`🚀 Server running on http://localhost:${PORT}`);
    }).on('error', (err) => {
        console.error("❌ Server failed to start:", err.message);
    });

})();
