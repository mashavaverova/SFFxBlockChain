export function convertBigInt(obj) {
    if (typeof obj === "bigint") {
        return obj.toString();  // Convert BigInt to string
    } else if (Array.isArray(obj)) {
        return obj.map(convertBigInt);  // Convert each item in an array
    } else if (typeof obj === "object" && obj !== null) {
        return Object.fromEntries(
            Object.entries(obj).map(([key, value]) => [key, convertBigInt(value)])
        );
    }
    return obj;  // Return other types unchanged
}
