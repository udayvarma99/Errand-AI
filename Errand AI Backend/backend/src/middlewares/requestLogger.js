// backend/src/middlewares/requestLogger.js
// Simple middleware to log incoming HTTP requests.

const logger = require('../utils/logger'); // Assuming logger utility exists

const requestLogger = (req, res, next) => {
    const start = Date.now();
    // Log request details when response finishes
    res.on('finish', () => {
        const duration = Date.now() - start;
        const { method, originalUrl } = req;
        const { statusCode } = res;
        logger.info(`${method} ${originalUrl} - ${statusCode} (${duration}ms)`);
    });
    // Log request details immediately (optional)
    // logger.debug(`Incoming Request: ${req.method} ${req.originalUrl} from ${req.ip}`);
    next(); // Pass control to the next middleware/route handler
};

module.exports = requestLogger;