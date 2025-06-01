// backend/src/middlewares/errorHandler.js
// Centralized error handling middleware for Express.

const logger = require('../utils/logger'); // Assuming logger utility exists
const config = require('../config');

const errorHandler = (err, req, res, next) => {
    // Log the error internally
    logger.error(`Error occurred on ${req.method} ${req.originalUrl}: ${err.message}`);
    // Log stack trace in development for debugging
    if (config.nodeEnv === 'development') {
        logger.error(err.stack);
    }

    // Determine status code: use error's status code or default to 500
    const statusCode = err.statusCode || err.status || 500;

    // Prepare user-facing error message
    let message = 'An unexpected internal server error occurred.';
    // If it's a client-side error (4xx), use the error's message directly
    if (statusCode >= 400 && statusCode < 500 && err.message) {
        message = err.message;
    }
    // In development, you might want to expose more details
    if (config.nodeEnv === 'development' && err.message){
         message = err.message; // Show specific message in dev
    }


    // Send JSON error response
    res.status(statusCode).json({
        status: 'error',
        statusCode: statusCode,
        message: message,
        // Optionally include error type or stack in development
         ...(config.nodeEnv === 'development' && { errorType: err.name, stack: err.stack })
    });
};

module.exports = errorHandler;