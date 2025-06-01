// backend/src/models/User.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
    email: {
        type: String,
        required: [true, 'Please provide an email'],
        unique: true,
        match: [ // Basic email format validation
            /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
            'Please add a valid email'
        ],
        lowercase: true,
        trim: true,
    },
    password: {
        type: String,
        required: [true, 'Please add a password'],
        minlength: 6,
        select: false // Don't send password back by default in queries
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
    // Add other fields like name if needed
});

// --- Password Hashing Middleware (Before Saving) ---
UserSchema.pre('save', async function(next) {
    // Only run this function if password was actually modified (or is new)
    if (!this.isModified('password')) {
        return next();
    }
    try {
        // Generate salt & hash password
        const salt = await bcrypt.genSalt(10); // 10 rounds is generally secure enough
        this.password = await bcrypt.hash(this.password, salt);
        next();
    } catch (err) {
        next(err); // Pass error to next middleware/error handler
    }
});

// --- Method to Compare Entered Password with Hashed Password ---
UserSchema.methods.matchPassword = async function(enteredPassword) {
    // 'this.password' refers to the hashed password in the database document
    // We need to ensure the password field was selected if we didn't use .select('+password') in the query
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);