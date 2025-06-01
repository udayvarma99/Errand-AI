// backend/src/middlewares/authMiddleware.js
// backend/src/middlewares/authMiddleware.js
const jwt = require('jsonwebtoken');
const User = require('../models/User'); // Ensure this path is correct
const config = require('../config');   // To get JWT_SECRET

exports.protect = async (req, res, next) => {
    const timestamp = new Date().toISOString();
    console.log(`\n--- [PROTECT MIDDLEWARE @ ${timestamp}] ---`);
    console.log(`[Protect] Request: ${req.method} ${req.originalUrl}`);
    let token;

    try {
        // 1. Extract token
        if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
            token = req.headers.authorization.split(' ')[1];
            console.log("[Protect] Token found in Bearer header (first 15 chars):", token ? token.substring(0, 15) + "..." : "null or empty");
        } else {
            console.warn("[Protect] No 'Bearer' token in Authorization header.");
            const error = new Error('Authorization token is missing or not Bearer type.');
            error.statusCode = 401;
            return next(error); // Explicitly pass error to Express error handler
        }

        // 2. Check if token is actually extracted
        if (!token) { // Should be caught above, but good to be defensive
            console.error("[Protect] FAILURE: Token variable is empty after extraction attempt.");
            const error = new Error('Authorization token is required.');
            error.statusCode = 401;
            return next(error);
        }

        // 3. Verify JWT_SECRET is available from config
        const secret = config.jwtSecret;
        if (!secret) {
            console.error('FATAL PROTECT ERROR: JWT_SECRET is NOT DEFINED in server configuration!');
            // This is a server configuration issue, should ideally halt server or throw critical error
            const error = new Error('Server authentication configuration error.');
            error.statusCode = 500; // Internal Server Error
            return next(error);
        }
        console.log(`[Protect] Verifying token with secret (starts with: ${secret.substring(0,5)}...)`);

        // 4. Verify the token using jwt.verify
        const decoded = jwt.verify(token, secret); // This can throw errors (TokenExpiredError, JsonWebTokenError)
        console.log("[Protect] Token decoded successfully:", decoded);

        if (!decoded || !decoded.id) {
            console.error("[Protect] FAILURE: Decoded token is invalid or missing 'id' field.");
            const error = new Error('Invalid token: User identifier missing.');
            error.statusCode = 401;
            return next(error);
        }

        // 5. Find user in database
        console.log(`[Protect] Attempting User.findById('${decoded.id}')`);
        // Ensure password is NOT selected unless explicitly needed elsewhere (which it isn't here)
        const userFromDb = await User.findById(decoded.id).select('-password');

        if (!userFromDb) {
            console.error(`[Protect] FAILURE: User NOT FOUND in DB for ID: ${decoded.id} (from token).`);
            const error = new Error('User associated with this token no longer exists.');
            error.statusCode = 401;
            return next(error);
        }

        // 6. Attach user to request object
        req.user = userFromDb; // This is the Mongoose document
        console.log(`[Protect] User FOUND and ATTACHED to req.user: Email=${req.user.email}, ID=${req.user._id}`);

        // --- Final check before calling next() ---
        if (!req.user || !req.user._id) {
            console.error("[Protect] CRITICAL FAILURE: req.user OR req.user._id is MISSING after assignment and just before next()!");
            const error = new Error('Internal server error during authentication processing.');
            error.statusCode = 500;
            return next(error);
        }
        // -----------------------------------------

        console.log("[Protect] SUCCESS: Authentication complete. Calling next() to proceed to controller.");
        next(); // Proceed to the controller function

    } catch (err) { // Catch errors from jwt.verify or any other unexpected errors
        let errorMessage = 'Not authorized (Token processing failed)';
        let errorStatusCode = 401;

        if (err.name === 'JsonWebTokenError') {
            console.error("[Protect] JWT Error:", err.message);
            errorMessage = 'Invalid token provided.';
        } else if (err.name === 'TokenExpiredError') {
            console.error("[Protect] JWT Error: Token has expired.");
            errorMessage = 'Your session has expired. Please log in again.';
        } else {
            // For other errors (like missing JWT_SECRET caught above or unexpected issues)
            console.error("[Protect] Unexpected error during token verification:", err.message, err.stack);
            errorMessage = err.message || 'Authentication process failed.';
            errorStatusCode = err.statusCode || 500; // Use error's status code or default to 500
        }

        const error = new Error(errorMessage);
        error.statusCode = errorStatusCode;
        return next(error); // Pass error to Express error handler
    }
};