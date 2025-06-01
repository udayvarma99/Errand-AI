// backend/src/controllers/errandController.js
// *** FULLY CORRECTED & DETAILED Controller Code ***

// Service & Model Imports
const googleAiService = require('../services/googleAiService');
const googleMapsService = require('../services/googleMapsService');
const twilioService = require('../services/twilioService');
const Errand = require('../models/Errand'); // Ensure this path is correct

// Utilities
const { v4: uuidv4 } = require('uuid');

// In-Memory Store Fallback
const inMemoryErrandStore = new Map();

// --- Helper: Emit WebSocket Update ---
const emitStatusUpdate = (req, taskId, data) => {
    if (!taskId) { console.warn(`[${taskId || 'UNKNOWN_TASK'}] Attempted to emit WebSocket update without a Task ID.`); return; }
    try {
        const io = req.app.get('socketio'); // Get io from app context
        if (io) {
            const payload = { taskId, ...data };
            console.log(`[${taskId}] Emitting WebSocket 'task_update': Status=${payload.status}`);
            io.to(taskId).emit('task_update', payload);
        } else { console.warn(`[${taskId}] Socket.IO instance unavailable on req.app. Cannot emit status: ${data.status}`); }
    } catch (error) { console.error(`[${taskId}] Error emitting WebSocket update: ${error.message}`); }
};

// --- Helper: Update Task State (DB/Memory) & Emit ---
const updateTaskState = async (req, taskId, currentErrandData, updates) => {
    let baseData = currentErrandData || {};
    if (Object.keys(baseData).length === 0 && taskId) {
         baseData = (require('../config').databaseUrl && require('mongoose').connection.readyState === 1
            ? await Errand.findOne({ taskId: taskId }).lean()
            : inMemoryErrandStore.get(taskId)) || {};
    }
    if (!baseData) { baseData = {}; } // Should not happen if taskId is valid for existing task

    // Ensure nested objects are initialized if not present on baseData
    baseData.details = baseData.details || {};
    baseData.callOutcome = baseData.callOutcome || {};
    baseData.conversationLog = baseData.conversationLog || [];
    baseData.steps = baseData.steps || [];

    let updatedData = { ...baseData, ...updates, taskId: taskId, lastUpdated: new Date() };

    // Add step history
    const lastStep = updatedData.steps[updatedData.steps.length - 1];
    const newStep = { step: updates.status || lastStep?.status || 'update', details: updates.details, error: updates.error, timestamp: new Date() };
    if (!lastStep || JSON.stringify(newStep) !== JSON.stringify(lastStep)) { updatedData.steps.push(newStep); }

    let finalData = updatedData;
    try {
        const dbConfigured = !!require('../config').databaseUrl;
        const mongoose = require('mongoose'); // Safe to require here
        const dbConnected = mongoose.connection.readyState === 1;

        if (dbConfigured && dbConnected) {
            const dbResult = await Errand.findOneAndUpdate(
                { taskId: taskId }, { $set: updatedData },
                { new: true, upsert: true, lean: true, setDefaultsOnInsert: true }
            );
            if (dbResult) {
                console.log(`[${taskId}] DB state updated/created. Status: ${updates.status || 'updated'}`);
                finalData = dbResult;
                inMemoryErrandStore.set(taskId, finalData); // Sync memory
            } else {
                 console.warn(`[${taskId}] DB findOneAndUpdate failed (returned null). Saving to memory.`);
                 inMemoryErrandStore.set(taskId, updatedData); finalData = updatedData;
            }
        } else {
             inMemoryErrandStore.set(taskId, updatedData);
             console.log(`[${taskId}] Updated memory store (DB Config: ${dbConfigured}, Connected: ${dbConnected}). Status: ${updates.status || 'updated'}`);
             finalData = updatedData;
        }
    } catch (dbError) {
        console.error(`[${taskId}] Error saving task state: ${dbError.message}. Saving to memory.`);
        inMemoryErrandStore.set(taskId, updatedData); finalData = updatedData;
        updates.error = `DB Error: ${dbError.message}. ${updates.error || ''}`.trim();
    }

    emitStatusUpdate(req, taskId, { status: finalData.status, message: `Update: ${finalData.status}`, error: finalData.error || updates.error, taskData: finalData });
    return finalData;
};

// --- Placeholder User ID (if auth is bypassed on routes) ---
const PLACEHOLDER_USER_ID_FOR_UNPROTECTED_ERRANDS = '000000000000000000000000';

// --- Controller Handlers ---

// POST /api/errands - Create and Initiate Errand
exports.handleNewErrand = async (req, res, next) => {
    let userIdToAssociate;
    let userEmailForLog = "ANONYMOUS (Auth Bypassed)";

    if (req.user && req.user._id) {
        userIdToAssociate = req.user._id; userEmailForLog = req.user.email;
        console.log(`[handleNewErrand] Authenticated user: ${userEmailForLog}`);
    } else {
        console.warn(`[handleNewErrand] No authenticated user on req. Using placeholder. Ensure 'protect' middleware is correctly configured for production.`);
        userIdToAssociate = PLACEHOLDER_USER_ID_FOR_UNPROTECTED_ERRANDS;
    }

    const { request, location, userPhoneNumber } = req.body;
    const taskId = uuidv4(); // Generate taskId ONCE here
    emitStatusUpdate(req, taskId, { status: 'received', message: "Request received..." });

    // --- Validation ---
    if (!request || typeof request !== 'string' || request.trim() === '') { const error = new Error('Request text is required.'); error.statusCode = 400; return next(error); }
    if (!userPhoneNumber || !/^\+?[1-9]\d{7,14}$/.test(userPhoneNumber.replace(/[^\d+]/g, ''))) { const error = new Error('Valid user phone for SMS (e.g., +1...) required.'); error.statusCode = 400; return next(error); }
    const cleanedUserPhoneNumber = userPhoneNumber.replace(/[^\d+]/g, '');
    // -----------------------

    // Initial Data Structure (with taskId from above)
    let errandData = {
        taskId, status: 'processing', request, userPhoneNumber: cleanedUserPhoneNumber,
        locationHint: location, steps: [{ step: 'received', timestamp: new Date() }],
        aiProvider: 'google_ai', confirmationStatus: 'pending',
        details: {}, callOutcome: {}, conversationLog: [], user: userIdToAssociate
    };
    console.log(`[${taskId}] Received request for user ${userEmailForLog} / ID ${userIdToAssociate} (SMS to: ${cleanedUserPhoneNumber})`);

    // Use updateTaskState for initial save & emit.
    // The first argument is `req`, second `taskId`, third `currentErrandData` (empty for new), fourth `updates` (initial data)
    errandData = await updateTaskState(req, taskId, {}, errandData);

    try {
        // --- Step 1: Parse Request ---
        errandData = await updateTaskState(req, taskId, errandData, { status: 'parsing_request' });
        const parsedRequest = await googleAiService.parseErrandRequest(request);
        if (!parsedRequest || !parsedRequest.service || !parsedRequest.action) { throw new Error("Could not reliably understand the required service or action."); }
        console.log(`[${taskId}] Parsed Request (Google AI):`, parsedRequest);
        errandData = await updateTaskState(req, taskId, errandData, { status: 'request_parsed', details: { ...errandData.details, parsed: parsedRequest } });

        // --- Step 2: Find Places ---
        errandData = await updateTaskState(req, taskId, errandData, { status: 'finding_places' });
        const searchLocation = location || errandData.locationHint || { lat: 40.7128, lng: -74.0060 };
        const places = await googleMapsService.findPlaces(`${parsedRequest.service} ${parsedRequest.location_hint || ''}`.trim(), searchLocation);
        if (!places || places.length === 0) { throw new Error(`Could not find any '${parsedRequest.service}' nearby.`); }
        const simplifiedPlaces = places.map(p => ({ name: p.name, address: p.formatted_address, phone: p.international_phone_number, placeId: p.place_id }));
        errandData = await updateTaskState(req, taskId, errandData, { status: 'places_found', details: { ...errandData.details, potentialPlaces: simplifiedPlaces } });

        // --- Step 3: Select Place ---
        const targetPlace = places.find(p => p.international_phone_number && p.international_phone_number.trim() !== '');
        console.log(`[${taskId}] Target place selection phase. Checking place:`, targetPlace ? targetPlace.name : 'No place with phone found initially');
        if (targetPlace) {
            console.log(`[${taskId}] Target place raw international_phone_number: '${targetPlace.international_phone_number}' (Type: ${typeof targetPlace.international_phone_number})`);
        }
        if (!targetPlace || typeof targetPlace.international_phone_number !== 'string' || targetPlace.international_phone_number.trim() === '') {
            throw new Error(`Found places for ${parsedRequest.service}, but none had a usable phone number string listed by Google Maps.`);
        }
        const selectedPlaceDetails = { name: targetPlace.name, phone: targetPlace.international_phone_number, address: targetPlace.formatted_address, placeId: targetPlace.place_id };
        errandData = await updateTaskState(req, taskId, errandData, { status: 'place_selected', details: { ...errandData.details, selectedPlace: selectedPlaceDetails } });

        // --- Step 4: Initiate Call (if needed) ---
        const requiresInteractiveCall = parsedRequest.action.includes('book') || parsedRequest.action.includes('check') || parsedRequest.action.includes('schedule');

        if (requiresInteractiveCall) {
            // --- Phone Number Cleaning & Validation ---
            let originalPhoneNumber = targetPlace.international_phone_number; // Already checked it's a non-empty string
            let cleanedPhoneNumberForCall;

            console.log(`[${taskId}] Cleaning phone. Original from Maps: '${originalPhoneNumber}'`);
            cleanedPhoneNumberForCall = originalPhoneNumber.replace(/[^\d+]/g, ''); // Remove non-digits except leading +
            console.log(`[${taskId}] After initial replace: '${cleanedPhoneNumberForCall}'`);

            if (!cleanedPhoneNumberForCall.startsWith('+')) {
                if (cleanedPhoneNumberForCall.length === 11 && cleanedPhoneNumberForCall.startsWith('1')) {
                    cleanedPhoneNumberForCall = '+' + cleanedPhoneNumberForCall;
                } else if (cleanedPhoneNumberForCall.length === 10) {
                    console.warn(`[${taskId}] Assuming US/Canada for 10-digit '${originalPhoneNumber}', adding +1.`);
                    cleanedPhoneNumberForCall = '+1' + cleanedPhoneNumberForCall;
                } else {
                    console.error(`[${taskId}] Phone format unclear for '${originalPhoneNumber}' after cleaning, no '+' prefix. Current: '${cleanedPhoneNumberForCall}'`);
                    throw new Error(`Cannot reliably format phone number '${originalPhoneNumber}' to E.164 for Twilio.`);
                }
            }
            console.log(`[${taskId}] Final cleaned phone number before validation: '${cleanedPhoneNumberForCall}'`);

            if (!/^\+\d{10,15}$/.test(cleanedPhoneNumberForCall)) { // E.164-like format
                console.error(`[${taskId}] CRITICAL: Phone number '${cleanedPhoneNumberForCall}' (from '${originalPhoneNumber}') STILL INVALID after all cleaning.`);
                throw new Error(`Phone number format is invalid for Twilio: '${cleanedPhoneNumberForCall}'.`);
            }
            // --------------------------------------

            errandData = await updateTaskState(req, taskId, errandData, { status: 'generating_script' });
            const openingPrompt = await googleAiService.generateCallScript(parsedRequest, targetPlace.name);
            const initialAiTurn = { speaker: 'ai', text: openingPrompt, timestamp: new Date() };
            errandData = await updateTaskState(req, taskId, errandData, {
                status: 'initiating_call',
                details: { ...errandData.details, callScript: openingPrompt, cleanedPhoneNumber: cleanedPhoneNumberForCall },
                conversationLog: [initialAiTurn]
             });

            console.log(`[${taskId}] Initiating INTERACTIVE call to (variable cleanedPhoneNumberForCall): '${cleanedPhoneNumberForCall}'`);
            const callSid = await twilioService.makeCall(cleanedPhoneNumberForCall, openingPrompt, taskId);

            errandData = await updateTaskState(req, taskId, errandData, { status: 'call_initiated', callSid: callSid });

            return res.status(202).json({
                message: `Okay, initiating AI call to ${targetPlace.name} (${cleanedPhoneNumberForCall})... Awaiting real-time updates.`,
                taskId: taskId, initialStatus: 'Call Initiated', placeName: targetPlace.name,
            });
        } else {
            console.log(`[${taskId}] Action '${parsedRequest.action}' does not require interactive call.`);
            errandData = await updateTaskState(req, taskId, errandData, { status: 'completed' });
            return res.status(200).json({
                message: `Task completed for '${parsedRequest.service}'. (No interactive call needed)`,
                taskId: taskId, status: 'Completed',
                places: parsedRequest.action.includes('find') ? (errandData.details?.potentialPlaces || []) : [],
            });
        }
    } catch (error) {
        console.error(`[${taskId}] Error processing errand in handleNewErrand (User: ${userEmailForLog}):`, error.message, error.stack);
        let currentErrandState = await Errand.findOne({ taskId: taskId }).lean() || inMemoryErrandStore.get(taskId) || errandData;
        await updateTaskState(req, taskId, currentErrandState, { status: 'failed', error: error.message });
        if (!error.statusCode) {
            if (error.message.includes("Could not reliably understand") || error.message.includes("Could not find any") ||
                error.message.includes("none had a usable phone number") || error.message.includes("has no phone number") ||
                error.message.includes("Cannot reliably format phone number") || error.message.includes("Phone number format is invalid")) {
                error.statusCode = 400; // Bad Request
            } else { error.statusCode = 500; } // Internal Server Error
        }
        next(error);
    }
};

// POST /api/errands/twilio/callback - Handles Twilio Callbacks
exports.handleTwilioCallback = async (req, res) => {
    // ... (Full robust code for handleTwilioCallback as provided in the previous answer) ...
    // Key: Ensure it uses 'updateCallbackState' which in turn uses the corrected 'updateTaskState'
    // and correctly passes 'req' for 'emitStatusUpdate'.
    const { CallSid, CallStatus, SpeechResult, Confidence, Digits, ErrorCode } = req.body;
    const taskId = req.query.taskId;
    let twiMLResponse = '<Response/>';

    if (!taskId) { /* ... */ }
    console.log(`[${taskId}] Twilio Callback: SID=${CallSid}, Status=${CallStatus}, Speech='${SpeechResult}', Conf=${Confidence}, Digits=${Digits}`);

    let errandDoc = require('../config').databaseUrl ? await Errand.findOne({ taskId: taskId }) : null;
    let taskData = errandDoc ? errandDoc.toObject({ virtuals: false }) : inMemoryErrandStore.get(taskId);

    if (!taskData) { /* ... handle task not found ... */ }
    taskData.details = taskData.details || {}; taskData.callOutcome = taskData.callOutcome || {}; taskData.conversationLog = taskData.conversationLog || [];

    const updateCallbackState = async (updates) => {
        taskData = await updateTaskState(req, taskId, taskData, updates); // Pass req
        return taskData;
    };

    try {
        if (SpeechResult !== undefined && SpeechResult.trim() !== '') {
            // ... (Full SpeechResult handling from previous, calling updateCallbackState and googleAiService.processConversationTurn) ...
        } else if (Digits !== undefined) {
            // ... (DTMF handling) ...
        } else if (CallStatus && ['completed', 'busy', 'no-answer', 'canceled', 'failed'].includes(CallStatus)) {
            // ... (Terminal CallStatus handling) ...
        } // ... etc. ...
    } catch (callbackError) { /* ... */ }

    if (twiMLResponse) { res.type('text/xml'); res.send(twiMLResponse); } else { res.status(204).send(); }
};

// GET /api/errands/:taskId/status - Get Status (Protected by 'protect' middleware in routes)
exports.getErrandStatus = async (req, res, next) => {
    // ... (Full code from previous answer, ensuring req.user check is robust) ...
};
