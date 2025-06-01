// backend/src/services/twilioService.js
// *** Ensures twilioSDKClient is properly declared, initialized, and checked ***

const twilio = require('twilio');
const config = require('../config'); // For credentials and baseUrl

// --- Declare twilioSDKClient at the module level, initialize to null ---
let twilioSDKClient = null;
// --------------------------------------------------------------------

// --- Attempt to Initialize client when the module is loaded ---
const accountSid = config.twilioAccountSid;
const authToken = config.twilioAuthToken;
const twilioPhoneNumberFromConfig = config.twilioPhoneNumber; // For clarity and validation
const baseUrlFromConfig = config.baseUrl;

// Check if all necessary Twilio credentials are present
if (accountSid && authToken && twilioPhoneNumberFromConfig) {
    try {
        // Initialize the Twilio SDK client
        twilioSDKClient = twilio(accountSid, authToken); // Assign to the module-level variable
        console.log("Twilio SDK client initialized successfully.");
    } catch (error) {
        // This catch is for errors during the twilio(sid, token) constructor call itself
        console.error("FATAL ERROR: Failed to initialize Twilio SDK client:", error.message, error.stack);
        // twilioSDKClient will remain null
    }
} else {
    console.warn("WARNING: Twilio credentials (TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, or TWILIO_PHONE_NUMBER) are not fully set in .env. Twilio features will be disabled.");
    // twilioSDKClient remains null
}

// Warn about BASE_URL if Twilio is otherwise configured (as it's needed for callbacks)
if (!baseUrlFromConfig && twilioSDKClient) { // Only warn if client was expected to be initialized
    console.warn("Warning: BASE_URL is not set in .env. Twilio callbacks will likely fail.");
}
// ---------------------------------------------------------

/**
 * Initiates an interactive outbound call using Twilio <Gather input="speech">.
 * @param {string} toPhoneNumber - Destination E.164 number.
 * @param {string} initialPrompt - The first thing the AI assistant should say.
 * @param {string} taskId - The unique task ID for callbacks.
 * @returns {Promise<string>} - Twilio Call SID.
 */
async function makeCall(toPhoneNumber, initialPrompt, taskId) {
  // --- CRITICAL CHECK: Use the module-level twilioSDKClient ---
  if (!twilioSDKClient) {
    console.error("Twilio makeCall Error: Twilio SDK client is NOT INITIALIZED. Check API credentials in .env and server startup logs.");
    // This specific error message should appear if keys were missing or client init failed
    throw new Error("Twilio service is currently unavailable. Please check server configuration.");
  }
  // --------------------------------------------------------

  // Validate other necessary parameters
  if (!taskId) { throw new Error("Task ID is required for Twilio callback URL."); }
  if (!baseUrlFromConfig) { throw new Error("BASE_URL not configured; Twilio callbacks will fail."); }

  // Phone number validation
  if (!toPhoneNumber || !/^\+?[1-9]\d{1,14}$/.test(toPhoneNumber)) {
      throw new Error(`Invalid 'to' phone number format provided for Twilio call: ${toPhoneNumber}`);
  }
  if (!twilioPhoneNumberFromConfig || !/^\+?[1-9]\d{1,14}$/.test(twilioPhoneNumberFromConfig)) {
      throw new Error(`Invalid 'from' (Twilio) phone number in server configuration: ${twilioPhoneNumberFromConfig}`);
  }
  if (!initialPrompt || typeof initialPrompt !== 'string' || initialPrompt.trim() === '') {
      console.warn(`[${taskId}] Twilio makeCall: initialPrompt is empty. Call might be silent initially.`);
      // Proceeding, but this is unusual.
  }

  const callbackUrl = `${baseUrlFromConfig}/api/errands/twilio/callback?taskId=${encodeURIComponent(taskId)}`;
  console.log(`Twilio makeCall: Using Callback URL (Speech Gather & Status): ${callbackUrl}`);

  const hintsForGather = "yes, no, okay, confirm, cancel, appointment, schedule, time, date, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, AM, PM, o'clock, one, two, three, four, five, six, seven, eight, nine, zero";
  const twiML = `
    <Response>
      <Gather input="speech"
              action="${callbackUrl}"
              method="POST"
              speechTimeout="auto"
              language="en-US"
              profanityFilter="true"
              hints="${hintsForGather}">
        <Say voice="alice" language="en-US">${initialPrompt}</Say>
      </Gather>
      <Say voice="alice" language="en-US">I'm sorry, I didn't catch a response. I will have to end the call. Goodbye.</Say>
      <Hangup/>
    </Response>`;

  try {
    console.log(`Twilio makeCall: Initiating call from ${twilioPhoneNumberFromConfig} to ${toPhoneNumber}`);
    // *** Use the correctly scoped and checked twilioSDKClient ***
    const call = await twilioSDKClient.calls.create({
        twiml: twiML,
        to: toPhoneNumber,
        from: twilioPhoneNumberFromConfig,
        statusCallback: callbackUrl, // For terminal call status updates
        statusCallbackEvent: ['completed', 'failed', 'busy', 'no-answer', 'canceled'],
        statusCallbackMethod: 'POST',
    });
    // ***********************************************************

    console.log(`Twilio makeCall: Call initiated successfully. Call SID: ${call.sid}`);
    return call.sid;

  } catch (error) {
    console.error(`Twilio makeCall Error: Failed to create call to ${toPhoneNumber}:`, error.message);
    if (error.code) { // Twilio-specific error object structure
        console.error(`Twilio Error Code: ${error.code}, More Info: ${error.moreInfo}`);
        throw new Error(`Twilio API Error ${error.code}: ${error.message}`);
    }
    // For other types of errors (e.g., network issues before hitting Twilio)
    throw new Error(`Failed to initiate Twilio call. Details: ${error.message}`);
  }
}

/**
 * Sends an SMS message using Twilio Messaging.
 */
async function sendSms(toPhoneNumber, messageBody) {
  // --- CRITICAL CHECK: Use the module-level twilioSDKClient ---
  if (!twilioSDKClient) {
    console.error("Twilio sendSms Error: Twilio SDK client is NOT INITIALIZED. Check API credentials in .env and server startup logs.");
    throw new Error("Twilio SMS service is not available due to missing configuration or initialization error.");
  }
  // --------------------------------------------------------

  if (!toPhoneNumber || !/^\+?[1-9]\d{1,14}$/.test(toPhoneNumber)) { throw new Error(`Invalid 'to' phone number for SMS: ${toPhoneNumber}`); }
  if (!messageBody || typeof messageBody !== 'string' || messageBody.trim().length === 0) { throw new Error("SMS message body cannot be empty."); }
  if (!twilioPhoneNumberFromConfig) { throw new Error("Twilio 'from' phone number not configured for SMS in server config.");}

  console.log(`Twilio sendSms: Attempting to send SMS from ${twilioPhoneNumberFromConfig} to ${toPhoneNumber}`);
  try {
    // *** Use the correctly scoped and checked twilioSDKClient ***
    const message = await twilioSDKClient.messages.create({
        body: messageBody,
        from: twilioPhoneNumberFromConfig,
        to: toPhoneNumber
    });
    // ***********************************************************
    console.log(`Twilio sendSms: SMS sent successfully. Message SID: ${message.sid}`);
    return message.sid;
  } catch (error) {
    console.error(`Twilio sendSms Error: Failed to send SMS to ${toPhoneNumber}:`, error.message);
    if (error.code) {
        console.error(`Twilio Error Code: ${error.code}, More Info: ${error.moreInfo}`);
        throw new Error(`Twilio SMS Error ${error.code}: ${error.message}`);
    }
    throw new Error(`Failed to send Twilio SMS. Details: ${error.message}`);
  }
}

module.exports = { makeCall, sendSms };