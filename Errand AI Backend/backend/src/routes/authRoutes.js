// backend/src/routes/authRoutes.js
const express = require('express');
const { register, login, getMe } = require('../controllers/authController'); // We'll create this controller next
const { protect } = require('../middlewares/authMiddleware'); // We'll create this middleware

const router = express.Router();

router.post('/register', register);
router.post('/login', login);
router.get('/me', protect, getMe); // Example protected route to get logged-in user info

module.exports = router;