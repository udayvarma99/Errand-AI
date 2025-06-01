// backend/src/routes/errandRoutes.js
// Defines the API routes related to errands and maps them to controller functions.

const express = require('express');
const errandController = require('../controllers/errandController'); // Check this line carefully

const router = express.Router();

// POST /api/errands - Create a new errand task
router.post('/', errandController.handleNewErrand);

// POST /api/errands/twilio/callback - Endpoint for Twilio status callbacks
router.post('/twilio/callback', errandController.handleTwilioCallback);

// GET /api/errands/:taskId/status - Get the current status of a task
router.get('/:taskId/status', errandController.getErrandStatus);

// Export the router
module.exports = router;