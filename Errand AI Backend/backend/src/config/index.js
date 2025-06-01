// backend/src/config/index.js
// Loads and exports configuration values, primarily from environment variables.

require('dotenv').config(); // Load variables from .env file into process.env

// Centralized configuration object
const config = {
  // Server configuration
  port: process.env.PORT || 5001,
  nodeEnv: process.env.NODE_ENV || 'development', // 'development', 'production', 'test'

  // Base URL for constructing callback URLs (Essential for Twilio)
  // Ensure it points to your publicly accessible server (e.g., ngrok URL in dev)
  // Remove trailing slash if present for consistency
  baseUrl: (process.env.BASE_URL || `http://localhost:${process.env.PORT || 5001}`).replace(/\/$/, ''),

  // API Keys and Credentials
  openaiApiKey: process.env.OPENAI_API_KEY, // Keep OpenAI key for potential fallback or future use
  googleApiKey: process.env.GOOGLE_API_KEY, // *** ADDED for Google AI ***
  googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY,
  twilioAccountSid: process.env.TWILIO_ACCOUNT_SID,
  twilioAuthToken: process.env.TWILIO_AUTH_TOKEN,
  twilioPhoneNumber: process.env.TWILIO_PHONE_NUMBER, // Your Twilio phone number

  // --- JWT Secret and Expiration ---  // <<< THESE WERE MISSING IN YOUR PASTED CODE
  jwtSecret: process.env.JWT_SECRET,  // <<< THIS IS THE KEY LINE
  jwtExpire: process.env.JWT_EXPIRE || '30d', // <<< THIS IS THE KEY LINE
// ---------------------------------

  // Database URL (for MongoDB connection)
  databaseUrl: process.env.DATABASE_URL, // e.g., mongodb://localhost:27017/errandAssistant

  // Optional: CORS configuration
  corsOrigin: process.env.CORS_ORIGIN || '*', // '*' allows all origins (use specific domains in production)

  // Optional: Logging level
  logLevel: process.env.LOG_LEVEL || 'info', // e.g., 'debug', 'info', 'warn', 'error'
};

// --- Configuration Validation (Optional but Recommended) ---
const validateConfig = () => {
    const requiredKeys = [
        // Add any keys absolutely essential for the server to start, e.g.:
        // 'googleMapsApiKey',
        // 'twilioAccountSid',
        // 'twilioAuthToken',
        // 'twilioPhoneNumber',
    ];
    const warnings = [];

    requiredKeys.forEach(key => {
        if (!config[key]) {
            console.error(`FATAL ERROR: Required configuration key "${key}" is missing in environment variables.`);
            process.exit(1); // Exit if critical config is missing
        }
    });

    // --- Non-critical warnings ---
    // Keep track of which AI service is likely active
    let primaryAiService = 'None';

    if (!config.googleApiKey) {
        warnings.push("GOOGLE_API_KEY is not set. Google AI features will be disabled."); // *** ADDED Warning ***
        if (!config.openaiApiKey) { // Only warn about OpenAI if Google AI is also missing
             warnings.push("OPENAI_API_KEY is not set. OpenAI features will be disabled.");
        } else {
            primaryAiService = 'OpenAI'; // OpenAI might be used as fallback
            warnings.push("GOOGLE_API_KEY not set, will attempt to use OpenAI if configured in controllers.");
        }
    } else {
        primaryAiService = 'GoogleAI'; // Google AI is present
        if (!config.openaiApiKey) {
             warnings.push("OPENAI_API_KEY is not set (Google AI key IS present).");
        }
    }


    if (!config.googleMapsApiKey) warnings.push("GOOGLE_MAPS_API_KEY is not set. Google Maps features will be disabled.");
    if (!config.twilioAccountSid || !config.twilioAuthToken || !config.twilioPhoneNumber) warnings.push("Twilio credentials are not fully set. Calling features will be disabled.");
    if (!config.databaseUrl) warnings.push("DATABASE_URL is not set. Persistence disabled, using in-memory store.");
    if (!process.env.BASE_URL && config.nodeEnv !== 'test') warnings.push("BASE_URL is not set. Twilio callbacks might fail.");
    if (config.corsOrigin === '*') warnings.push("CORS_ORIGIN is set to '*'. Restrict this in production for security.");


    if (warnings.length > 0) {
        console.warn("\n--- Configuration Warnings ---");
        warnings.forEach(warn => console.warn(`- ${warn}`));
        console.warn("----------------------------\n");
    }

    console.log("Configuration loaded successfully.");
    console.log(`Primary AI Service Expected: ${primaryAiService} (based on API key presence)`); // Indicate expected AI
    if(config.googleMapsApiKey) console.log("Google Maps API Key provided.");
    if(config.twilioAccountSid) console.log("Twilio credentials provided.");
    if(config.databaseUrl) console.log("Database URL provided.");
    if(config.baseUrl) console.log(`Base URL for callbacks: ${config.baseUrl}`);

};

// Run validation on startup
validateConfig();

// Export the configuration object
module.exports = config;