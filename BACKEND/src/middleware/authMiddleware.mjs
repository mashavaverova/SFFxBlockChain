import jwt from 'jsonwebtoken';
import { ENV } from '../config/environment.mjs';

// Middleware for Token Verification
export const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    if (!authHeader) return res.status(401).json({ error: 'Access Denied. No token provided.' });

    const token = authHeader.split(' ')[1];
    jwt.verify(token, ENV.jwtSecret, (err, user) => {
        if (err) return res.status(403).json({ error: 'Invalid or expired token.' });
        req.user = user;
        next();
    });
};

// Role-Based Access Control Middleware
export const authorizeRole = (roles) => (req, res, next) => {
    if (!roles.includes(req.user.role)) {
        return res.status(403).json({ error: 'Unauthorized access.' });
    }
    next();
};
