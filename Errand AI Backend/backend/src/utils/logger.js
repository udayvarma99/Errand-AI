// backend/src/utils/logger.js
// Basic logger utility (can be expanded with libraries like Winston or Pino)

const config = require('../config');

const levels = {
    error: 0,
    warn: 1,
    info: 2,
    debug: 3,
};

const currentLevel = levels[config.logLevel] ?? levels.info; // Default to 'info'

const log = (level, message, ...args) => {
    if (levels[level] <= currentLevel) {
        const timestamp = new Date().toISOString();
        console[level](`[${timestamp}] [${level.toUpperCase()}]`, message, ...args);
    }
};

module.exports = {
    error: (message, ...args) => log('error', message, ...args),
    warn: (message, ...args) => log('warn', message, ...args),
    info: (message, ...args) => log('info', message, ...args),
    debug: (message, ...args) => log('debug', message, ...args),
};

// You would then replace console.log/warn/error in other files with logger.info/warn/error