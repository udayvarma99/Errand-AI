// backend/src/services/googleAiService.js
// Interacts with the Google AI (Gemini) API for parsing, initial script generation, and conversation processing.

const { GoogleGenerativeAI, HarmCategory, HarmBlockThreshold } = require("@google/generative-ai");
const config = require('../config'); // Loads config including API keys

// --- Initialization ---
if (!config.googleApiKey) {
    console.error("WARNING: GOOGLE_API_KEY is not set. Google AI features will be disabled.");
}

// Initialize clients for different potential models or tasks if needed
const genAI = config.googleApiKey ? new GoogleGenerativeAI(config.googleApiKey) : null;

// Model for parsing the initial request (can be simpler/faster)
const PARSING_MODEL_NAME = "gemini-1.5-flash-latest"; // Good balance
const parsingModel = genAI ? genAI.getGenerativeModel({ model: PARSING_MODEL_NAME }) : null;

// Model for conversation (might need more power, e.g., gemini-pro if flash struggles)
const CONVERSATION_MODEL_NAME = "gemini-1.5-flash-latest"; // Start with flash, maybe change to "gemini-1.5-pro-latest" if needed
const convModel = genAI ? genAI.getGenerativeModel({
    model: CONVERSATION_MODEL_NAME,
    // Optional safety settings - adjust thresholds if calls get blocked unexpectedly
    // safetySettings: [
    //   { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
    //   { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
    //   { category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
    //   { category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT, threshold: HarmBlockThreshold.BLOCK_ONLY_HIGH },
    // ],
     generationConfig: {
         // stopSequences: ["\nHUMAN:", "\nAI:"], // Optional: Help model stop generating extra turns
         // maxOutputTokens: 150, // Limit response length for conversation turns
         temperature: 0.6, // Adjust creativity/focus balance
     }
}) : null;


/**
 * Parses the user's initial natural language request.
 */
async function parseErrandRequest(text) {
    if (!parsingModel) { throw new Error("Google AI client (parsing model) not initialized."); }
    if (!text) { throw new Error("Invalid input text for parsing."); }

    const prompt = `
      Analyze the user request for an errand assistant. Extract:
      1. "service": Primary service/business type (e.g., "dentist appointment", "plumber").
      2. "action": Main action (e.g., "book", "check availability", "call").
      3. "time_constraint": Any date/time mentioned (e.g., "tomorrow afternoon", "ASAP"), or null.
      4. "location_hint": Specific location hints (e.g., "downtown"), or null.

      User Request: "${text}"

      Respond ONLY with a valid JSON object containing these keys. Use null for missing values. Example:
      {
        "service": "plumber", "action": "check availability",
        "time_constraint": "tomorrow afternoon", "location_hint": null
      }
      JSON Output:`;

    console.log("[AI Parsing] Sending initial request to Google AI...");
    try {
        // Use the dedicated parsing model
        const result = await parsingModel.generateContent(prompt);
        const response = await result.response;
        const responseText = response.text().trim();

        if (!responseText) { throw new Error("Google AI returned empty response for parsing."); }
        console.log("[AI Parsing] Raw response:", responseText);

        // Extract JSON robustly
        const jsonMatch = responseText.match(/```json\s*([\s\S]*?)\s*```|({[\s\S]*})/);
        let jsonString = responseText;
        if (jsonMatch && (jsonMatch[1] || jsonMatch[2])) { jsonString = jsonMatch[1] || jsonMatch[2]; }
        else { console.warn("[AI Parsing] Could not extract JSON block, parsing whole response."); }

        const parsedJson = JSON.parse(jsonString);
        const expectedKeys = ["service", "action", "time_constraint", "location_hint"];
        const validatedJson = {};
        for (const key of expectedKeys) { validatedJson[key] = parsedJson[key] ?? null; } // Use nullish coalescing

        if (!validatedJson.service && !validatedJson.action) { throw new Error("Failed to extract essential service/action via Google AI."); }
        console.log("[AI Parsing] Parsed JSON:", validatedJson);
        return validatedJson;

    } catch (error) {
        console.error("[AI Parsing] Error during Google AI call:", error);
        if (error.message.includes('API key not valid')) { throw new Error("Invalid Google AI API key."); }
        if (error.message.includes('quota') || error.message.includes('rate limit')) { throw new Error("Google AI quota/rate limit hit."); }
        throw new Error(`Google AI request failed during parsing: ${error.message}`);
    }
}

/**
 * Generates the *opening* line for the AI call.
 */
async function generateCallScript(parsedRequest, placeName) {
    // Use the conversational model for consistency, even for the opening line
    if (!convModel) { throw new Error("Google AI client (conversation model) not initialized."); }
    if (!parsedRequest || !placeName) { throw new Error("Missing data for script generation."); }

    // Prompt for the first utterance, clearly stating the goal
    const prompt = `
      You are an AI assistant starting an automated call to "${placeName}" to ${parsedRequest.action || 'inquire about'} ${parsedRequest.service || 'their services'} for a user.
      ${parsedRequest.time_constraint ? `The user specified a time around: "${parsedRequest.time_constraint}".` : ''}
      Generate ONLY the single, natural-sounding opening sentence the AI should speak to state the purpose clearly and initiate the booking/checking process.
      Keep it concise (~15-25 words). Example: "Hello, this is an automated assistant calling for a user. I'd like to see if it's possible to book a dentist appointment for tomorrow afternoon."
      Generated Opening Sentence:`;

    console.log("[AI Script Gen] Sending request to Google AI...");
    try {
        const result = await convModel.generateContent(prompt);
        const response = await result.response;
        const script = response.text().trim().replace(/^["']|["']$/g, ''); // Clean quotes

        if (!script) { throw new Error("Empty opening script generated."); }
        console.log("[AI Script Gen] Generated opening script:", script);
        return script;

    } catch (error) {
        console.error("[AI Script Gen] Error generating opening script:", error);
        // Fallback
        const fallbackAction = parsedRequest.action || 'inquire about';
        const fallbackService = parsedRequest.service || 'services';
        const fallbackTime = parsedRequest.time_constraint ? ` regarding ${parsedRequest.time_constraint}` : '';
        return `Hello, this is an automated assistant calling for a user to ${fallbackAction} ${fallbackService}${fallbackTime}.`;
    }
}


/**
 * Processes one turn of the conversation based on human speech input.
 * Determines the AI's next action: speak, confirm, or fail.
 */
async function processConversationTurn(history, humanSpeech, goalDetails) {
    if (!convModel) { throw new Error("Google AI client (conversation model) not initialized."); }
    if (!history || !humanSpeech || !goalDetails) { throw new Error("Missing required data for conversation processing."); }

    // ** This prompt is crucial and needs refinement based on testing **
    const formattedHistory = history.map(turn => `${turn.speaker === 'ai' ? 'ASSISTANT' : 'HUMAN'}: ${turn.text}`).join('\n');
    const goal = `The assistant's primary goal is to successfully ${goalDetails.action || 'book'} a ${goalDetails.service || 'service'} ${goalDetails.time_constraint ? `for around ${goalDetails.time_constraint}` : 'at a suitable time'}.`;

    // Give the AI context, the latest human response, and clear instructions
    const prompt = `
      You are a helpful AI Appointment Booking Assistant having a phone conversation.
      Your goal: ${goal}

      Conversation History So Far:
      ${formattedHistory}

      Latest Response from the Human on the Phone:
      HUMAN: ${humanSpeech}

      Your Task:
      Analyze the HUMAN's latest response in the context of the conversation history and your goal.
      Decide your *next single action*. Choose ONE of the following outputs:

      1.  If the HUMAN's response clearly and unambiguously confirms the appointment is successfully booked for the requested time (or an agreed-upon time): Output ONLY the exact word: CONFIRMED

      2.  If the HUMAN's response clearly indicates the appointment cannot be booked as requested (e.g., unavailable, wrong number, refuses service): Output ONLY the exact word: DECLINED

      3.  If the conversation needs to continue to achieve the goal (e.g., clarify availability, ask for details, propose alternative times, handle questions): Output ONLY the *exact, single sentence* you should speak next. Keep it polite, concise, relevant, and focused on achieving the booking goal. Do not ask more than one question per turn. Examples: "Okay, is 4 PM available that day?", "Thank you. Could I get the patient's name please?", "Understood. Are there any openings the following day?".

      Output Format: Respond with ONLY "CONFIRMED", "DECLINED", or the single sentence to speak next. Do not add explanations.

      Your Decision/Response:`;

    console.log(`[AI Processing] Goal: ${goal}`);
    console.log(`[AI Processing] History Length: ${history.length}`);
    console.log(`[AI Processing] Last Human Speech: "${humanSpeech}"`);
    console.log(`[AI Processing] Sending context to Google AI...`);

    try {
        // Use the conversational model
        const result = await convModel.generateContent(prompt);
        const response = await result.response;
        // Attempt to access candidate text safely
        let aiDecision = '';
        if (response && response.candidates && response.candidates.length > 0 && response.candidates[0].content && response.candidates[0].content.parts && response.candidates[0].content.parts.length > 0) {
           aiDecision = response.candidates[0].content.parts[0].text.trim();
        } else {
            // Fallback or alternative text access if the structure differs or is blocked
            aiDecision = response?.text ? response.text().trim() : ''; // Check response.text() as fallback
            if (!aiDecision) {
                 console.warn("[AI Processing] Could not extract text from response candidate or response.text(). Response:", JSON.stringify(response, null, 2));
                 // Check for safety blocks
                 if (response?.promptFeedback?.blockReason) {
                     throw new Error(`AI response blocked due to safety settings: ${response.promptFeedback.blockReason}`);
                 }
                throw new Error("AI returned an empty or unreadable response.");
            }
        }


        console.log("[AI Processing] Raw AI Decision/Response:", aiDecision);

        const decisionUpper = aiDecision.toUpperCase();

        if (decisionUpper === "CONFIRMED") {
            return { nextAction: 'confirm', aiResponseText: null, finalStatusMessage: "AI confirmed appointment." };
        } else if (decisionUpper === "DECLINED") {
             return { nextAction: 'fail', aiResponseText: null, finalStatusMessage: "AI determined appointment declined/unavailable." };
        } else if (aiDecision.length > 0 && aiDecision.length < 250) { // Check if it looks like a sentence
             // Remove potential leading/trailing quotes or markdown
             const cleanedAiResponse = aiDecision.replace(/^["'“‘]|["'”’]$/g, '').replace(/^ASSISTANT:\s*/i, '').trim();
             if (cleanedAiResponse.length === 0) {
                console.warn("[AI Processing] AI generated an empty response after cleaning.");
                return { nextAction: 'fail', aiResponseText: null, finalStatusMessage: "AI processing error (empty response)." };
             }
             return { nextAction: 'speak', aiResponseText: cleanedAiResponse };
        } else {
             console.warn("[AI Processing] AI decision was invalid (empty, too long, or unexpected format):", aiDecision);
             return { nextAction: 'fail', aiResponseText: null, finalStatusMessage: "AI processing failed or response unclear." };
        }

    } catch (error) {
        console.error("[AI Processing] Error during Google AI conversation processing:", error);
        // Provide more specific error messages
         if (error.message.includes('SAFETY') || (error.response && error.response.promptFeedback?.blockReason)){
             return { nextAction: 'fail', aiResponseText: null, finalStatusMessage: `AI response blocked due to safety settings (${error.response?.promptFeedback?.blockReason || 'Unknown Reason'}).` };
         }
        throw new Error(`Google AI conversation processing failed: ${error.message}`);
    }
}


// Export all necessary functions
module.exports = {
    parseErrandRequest,
    generateCallScript,
    processConversationTurn
};
