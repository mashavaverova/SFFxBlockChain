import mongoose from 'mongoose';
import ENV from './environment.mjs'; // Ensure correct import

export const connectDB = async () => {
    try {
        if (!ENV.mongoUri) {
            throw new Error('MONGO_URI is not defined in environment variables.');
        }

        await mongoose.connect(ENV.mongoUri, {
            useNewUrlParser: true, 
            useUnifiedTopology: true, 
        });

        console.log('✅ Connected to MongoDB:', ENV.mongoUri);
    } catch (error) {
        console.error('❌ MongoDB connection error:', error.message);
        process.exit(1); // Exit the process if DB connection fails
    }
};

export default connectDB;
