// backend/src/server.js
// *** UPDATED for Correct Socket.IO Initialization & CORS ***
const config = require('./config');
const express = require('express');
const cors = require('cors'); // Still needed for HTTP requests
const mongoose = require('mongoose');
const path = require('path');
const http = require('http'); // Use Node's built-in http module
const { Server } = require("socket.io"); // Import the Server class

// --- Create Express App and HTTP Server FIRST ---
const app = express();
const server = http.createServer(app); // Create HTTP server wrapping the Express app

// --- Initialize Socket.IO Server using the HTTP server ---
console.log(`Initializing Socket.IO with CORS origin: ${config.corsOrigin}`); // Log CORS origin
const io = new Server(server, { // Pass the http server instance here
    cors: {
        origin: config.corsOrigin, // Allow connections from configured frontend origin (e.g., http://localhost:3000)
        methods: ["GET", "POST"] // Standard methods for CORS negotiation
    },
    // Explicitly define path if needed (though default /socket.io/ usually works)
    // path: "/socket.io/", // Usually not needed unless customizing path
    // Allow transport upgrades
    transports: ['websocket', 'polling']
});
console.log("Socket.IO server initialized and attached to HTTP server.");

// --- Store io instance on the app object for controllers ---
app.set('socketio', io);
// --------------------------------------------------------

// --- NOW Import other modules AFTER io is initialized ---
const requestLogger = require('./middlewares/requestLogger'); // Assuming path is correct
const errorHandler = require('./middlewares/errorHandler'); // Assuming path is correct
const errandRoutes = require('./routes/errandRoutes'); // Routes required after io init
const authRoutes = require('./routes/authRoutes'); // <<< Import Auth Routes

// --- Socket.IO Connection Logic ---
io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);
    socket.on('join_task_room', (taskId) => {
        if (taskId) {
            console.log(`Socket ${socket.id} joining room: ${taskId}`);
            socket.join(taskId); // Make the socket join the room
        } else {
            console.warn(`Socket ${socket.id} tried to join invalid room: ${taskId}`);
        }
    });
    socket.on('disconnect', (reason) => {
        console.log(`Socket disconnected: ${socket.id}, Reason: ${reason}`);
    });
    socket.on("connect_error", (err) => {
        console.error(`Socket Connect Error for ${socket.id}: ${err.message}`);
        // Log more details if available
        if (err.data) console.error(" Connect Error Data:", err.data);
    });
    // Optional: Catch all listener for debugging
    // socket.onAny((event, ...args) => {
    //   console.log(`Socket Event Received by server: ${event}`, args);
    // });
});


// --- Database Connection ---
const connectDB = async () => {
     if (!config.databaseUrl) { console.warn("DATABASE_URL not set, skipping DB connection."); return; }
     try { await mongoose.connect(config.databaseUrl, { serverSelectionTimeoutMS: 5000 });
           console.log('MongoDB Connected.');
           mongoose.connection.on('error', err => { console.error('MongoDB connection error:', err); });
     } catch (err) { console.error('MongoDB connection failed:', err.message); }
};
connectDB();


// --- Core Express Middleware ---
// Apply HTTP CORS *before* routes
app.use(cors({ origin: config.corsOrigin }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Apply request logger *after* CORS/parsing but *before* routes
app.use(requestLogger);


// --- API Routes ---
app.use('/api/errands', errandRoutes); // Define API routes
app.use('/api/auth', authRoutes); // <<< Mount Auth Routes
app.use('/api/errands', errandRoutes); // Keep Errand Routes


// --- Basic Root & Health Check ---
app.get('/', (req, res) => res.send(`AI Errand Assistant Backend (${config.nodeEnv}) Running!`));
app.get('/health', (req, res) => {
    const health = { status: 'UP', timestamp: new Date().toISOString(), database: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected' };
    res.status(200).json(health);
});


// --- Global Error Handler (AFTER routes) ---
app.use(errorHandler);


// --- Start the HTTP Server (which includes Socket.IO handling) ---
const PORT = config.port;
server.listen(PORT, () => { // MUST use server.listen()
  console.log(`--------------------------------------------------`);
  console.log(`  Backend Server (Express + Socket.IO)`);
  console.log(`  Listening on port ${PORT}`);
  console.log(`  Frontend connections expected from: ${config.corsOrigin}`); // Log expected frontend origin
  console.log(`  Base URL for Twilio callbacks: ${config.baseUrl}`);
  console.log(`--------------------------------------------------`);
});

// --- Graceful Shutdown ---
const gracefulShutdown = (signal) => {
    console.log(`\n${signal} received. Shutting down...`);
    io.close(() => {
         console.log('Socket.IO connections closed.');
         server.close(() => {
            console.log('HTTP server closed.');
            if (mongoose.connection.readyState === 1) { mongoose.connection.close(false, () => { console.log('MongoDB closed.'); process.exit(0); });}
            else { process.exit(0); }
         });
    });
    setTimeout(() => { console.error('Force shutdown.'); process.exit(1); }, 10000);
};
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
// ...