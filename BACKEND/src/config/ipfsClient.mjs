import { create } from 'ipfs-http-client';
import ENV from '../config/environment.mjs'; // Ensure environment variables are used

const ipfs = create({
    host: ENV.ipfsHost || '127.0.0.1', // Default to local IPFS node
    port: ENV.ipfsPort || 5001, // Default IPFS API port
    protocol: ENV.ipfsProtocol || 'http',
    headers: {
        'User-Agent': 'node.js',
    },
});

export default ipfs;
