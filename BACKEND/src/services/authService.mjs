import User from '../models/UserModel.mjs';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';
import { ENV } from '../config/environment.mjs';

// Register a User
export const registerUser = async (req, res) => {
    try {
        const { email, password, walletAddress, role } = req.body;

        // Ensure only allowed roles are registered
        if (!['PLATFORM_ADMIN', 'FUNDS_MANAGER', 'AUTHOR', 'BUYER'].includes(role)) {
            return res.status(400).json({ error: 'Invalid role.' });
        }

        const hashedPassword = password ? await bcrypt.hash(password, 10) : null;

        const user = new User({
            email,
            password: hashedPassword,
            walletAddress,
            role,
        });

        await user.save();

        const token = jwt.sign(
            { id: user._id, email: user.email, role: user.role, walletAddress: user.walletAddress },
            ENV.jwtSecret,
            { expiresIn: '1h' }
        );

        res.json({ token, user });
    } catch (err) {
        res.status(500).json({ error: 'Failed to register user.' });
    }
};

// Login a User
export const loginUser = async (req, res) => {
    try {
        const { identifier, password } = req.body;
        const isEmail = identifier.includes('@');
        const query = isEmail ? { email: identifier } : { walletAddress: identifier };

        const user = await User.findOne(query);
        if (!user) return res.status(400).json({ error: 'Invalid credentials.' });

        if (user.password) {
            const isMatch = await bcrypt.compare(password, user.password);
            if (!isMatch) return res.status(400).json({ error: 'Invalid credentials.' });
        }

        const accessToken = jwt.sign(
            { id: user._id, email: user.email, role: user.role, walletAddress: user.walletAddress },
            ENV.jwtSecret,
            { expiresIn: '1h' }
        );

        res.json({ accessToken });
    } catch (err) {
        res.status(500).json({ error: 'Failed to login user.' });
    }
};

// Logout (Placeholder for token revocation)
export const logoutUser = (req, res) => {
    res.status(200).json({ message: 'Logged out successfully' });
};

// Refresh Token
export const refreshToken = (req, res) => {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(401).json({ error: 'Refresh Token is required' });

    try {
        const decoded = jwt.verify(refreshToken, ENV.refreshTokenSecret);
        const newAccessToken = jwt.sign(
            { id: decoded.id, email: decoded.email, role: decoded.role, walletAddress: decoded.walletAddress },
            ENV.jwtSecret,
            { expiresIn: '1h' }
        );

        res.json({ accessToken: newAccessToken });
    } catch (err) {
        res.status(403).json({ error: 'Invalid or expired Refresh Token' });
    }
};

// Verify Token
export const verifyToken = (req, res) => {
    const { token } = req.body;
    if (!token) return res.status(401).json({ error: 'Token is required' });

    try {
        const decoded = jwt.verify(token, ENV.jwtSecret);
        res.json({ valid: true, user: decoded });
    } catch (err) {
        res.status(403).json({ valid: false, error: 'Invalid or expired Token' });
    }
};
