// backend/src/models/Errand.js
// *** Simplified for Non-Conversational Flow ***
const mongoose = require('mongoose');

const StepSchema = new mongoose.Schema({
    step: { type: String, required: true },
    timestamp: { type: Date, default: Date.now },
    details: { type: mongoose.Schema.Types.Mixed },
    error: { type: String }
}, { _id: false });

const ErrandSchema = new mongoose.Schema({
    taskId: { type: String, required: true, unique: true, index: true },
    request: { type: String, required: true, trim: true },
    userPhoneNumber: { type: String }, // User's phone for SMS
    status: {
        type: String,
        required: true,
        enum: [
            'processing', 'parsing_request', 'request_parsed',
            'finding_places', 'places_found', 'place_selected',
            'generating_script', 'initiating_call', 'call_initiated',
            'call_ringing', 'call_in_progress',      // Call answered, AI spoke/is speaking
            'awaiting_dtmf_confirmation', // If using DTMF gather
            'appointment_confirmed_dtmf', // User pressed 1
            'appointment_declined_dtmf',  // User pressed other key
            'appointment_failed_no_dtmf', // DTMF Gather timed out
            'sms_notification_sent', 'sms_notification_failed',
            'call_completed', // Generic call completion
            'call_failed_busy', 'call_failed_no_answer', 'call_canceled', 'call_failed',
            'completed', // Task completed without a call
            'failed'     // General task failure
        ],
        default: 'processing'
    },
    locationHint: { lat: { type: Number }, lng: { type: Number } },
    details: {
        parsed: { type: mongoose.Schema.Types.Mixed },
        potentialPlaces: [{ type: mongoose.Schema.Types.Mixed }],
        selectedPlace: { type: mongoose.Schema.Types.Mixed },
        callScript: { type: String }, // The one line AI says
        cleanedPhoneNumber: { type: String },
        dtmfInput: { type: String } // Store DTMF input if gathered
    },
    callSid: { type: String, index: true },
    callOutcome: {
        finalStatus: { type: String },
        dtmfInput: { type: String }, // Can also store here
        error: { type: String }
    },
    // confirmationStatus can be simplified or inferred from main status
    confirmationOutcome: { // Simplified outcome
        type: String,
        enum: ['pending', 'confirmed', 'declined', 'failed'],
        default: 'pending'
    },
    error: { type: String },
    steps: [StepSchema],
    aiProvider: { type: String, default: 'google_ai' },
    user: { type: mongoose.Schema.ObjectId, ref: 'User' /*, required: true */ },
    createdAt: { type: Date, default: Date.now },
    lastUpdated: { type: Date, default: Date.now }
}, {
    timestamps: { createdAt: 'createdAt', updatedAt: 'lastUpdated' }
});

module.exports = mongoose.model('Errand', ErrandSchema);