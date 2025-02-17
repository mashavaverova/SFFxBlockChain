import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
    email: { type: String, unique: true, sparse: true }, 
    password: {
        type: String,
        required: function () {
            return this.role !== 'DEFAULT_ADMIN';
        },
    },
    walletAddress: { type: String, required: true, unique: true },
    role: {
        type: String,
        enum: ['DEFAULT_ADMIN', 'PLATFORM_ADMIN', 'FUNDS_MANAGER', 'AUTHOR', 'BUYER'],
        default: 'BUYER', 
    },
});

export default mongoose.model('User', userSchema);
