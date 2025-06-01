// backend/src/controllers/authController.js
const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { validationResult } = require('express-validator'); // We'll add validation later

// --- Helper to generate JWT ---
const generateToken = (id) => {
    // Use a secret from environment variables!
    if (!process.env.JWT_SECRET) {
        console.error('FATAL ERROR: JWT_SECRET is not defined in .env');
        process.exit(1); // Exit if secret is missing
    }
     if (!process.env.JWT_EXPIRE) {
        console.warn('Warning: JWT_EXPIRE not set in .env, using default (e.g., 30d)');
     }

    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: process.env.JWT_EXPIRE || '30d', // e.g., '30d', '1h'
    });
};

// --- Send Token Response Helper ---
const sendTokenResponse = (user, statusCode, res) => {
    const token = generateToken(user._id);

    // Cookie options (optional, useful if frontend/backend on same domain or using proxies correctly)
    const options = {
        expires: new Date(Date.now() + (parseInt(process.env.JWT_COOKIE_EXPIRE_DAYS || '30', 10) * 24 * 60 * 60 * 1000)),
        httpOnly: true, // Cookie cannot be accessed by client-side JS
        secure: process.env.NODE_ENV === 'production', // Only send over HTTPS in production
        // sameSite: 'strict' // Or 'lax', helps prevent CSRF
    };

    // Remove password from user object before sending
    const userResponse = user.toObject();
    delete userResponse.password;

    // Send token in cookie (optional) and as JSON response
    res.status(statusCode)
       // .cookie('token', token, options) // Uncomment if using cookies for token storage
       .json({ success: true, token, user: userResponse });
};


// @desc    Register user
// @route   POST /api/auth/register
// @access  Public
exports.register = async (req, res, next) => {
    // Add input validation here using express-validator later
    const { email, password } = req.body;

    try {
        // Check if user already exists
        let user = await User.findOne({ email });
        if (user) {
             return res.status(400).json({ success: false, message: 'User already exists' });
            // Or use error handling middleware:
            // const error = new Error('User already exists'); error.statusCode = 400; return next(error);
        }

        // Create user
        user = await User.create({ email, password }); // Password hashing happens via mongoose 'pre save' hook

        // Create token and send response
        sendTokenResponse(user, 201, res); // 201 Created

    } catch (error) {
        console.error("Registration Error:", error);
        // Pass to error handling middleware
         next(error); // Mongoose errors (like validation) will be passed here
    }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
exports.login = async (req, res, next) => {
    // Add input validation here later
    const { email, password } = req.body;

    if (!email || !password) {
         return res.status(400).json({ success: false, message: 'Please provide email and password' });
        // const error = new Error('Please provide email and password'); error.statusCode = 400; return next(error);
    }

    try {
        // Find user by email, ensuring password field is selected
        const user = await User.findOne({ email }).select('+password');

        if (!user) {
             return res.status(401).json({ success: false, message: 'Invalid credentials' }); // 401 Unauthorized
            // const error = new Error('Invalid credentials'); error.statusCode = 401; return next(error);
        }

        // Check if password matches
        const isMatch = await user.matchPassword(password);

        if (!isMatch) {
             return res.status(401).json({ success: false, message: 'Invalid credentials' }); // 401 Unauthorized
            // const error = new Error('Invalid credentials'); error.statusCode = 401; return next(error);
        }

        // Password matches, send token
        sendTokenResponse(user, 200, res); // 200 OK

    } catch (error) {
        console.error("Login Error:", error);
        next(error);
    }
};

// @desc    Get current logged in user
// @route   GET /api/auth/me
// @access  Private
exports.getMe = async (req, res, next) => {
    // req.user is set by the 'protect' middleware
     if (!req.user) {
         // This shouldn't happen if 'protect' middleware runs correctly
         return res.status(401).json({ success: false, message: 'Not authorized' });
    }

    // Send back user data (excluding password)
    const userResponse = req.user.toObject();
    delete userResponse.password;

    res.status(200).json({
        success: true,
        user: userResponse
    });
};