# Local AI Errand Assistant - Backend

This is the backend server for the Local AI Errand Assistant application. It handles incoming requests, interacts with external APIs (OpenAI, Google Maps, Twilio), manages task state, and communicates results.

## Features

*   Parses natural language errand requests using OpenAI GPT.
*   Finds relevant local businesses using Google Maps Places API.
*   Initiates outbound phone calls via Twilio Programmable Voice.
*   Handles Twilio status callbacks to track call progress.
*   Provides API endpoints for frontend interaction.
*   Optional MongoDB integration for persistent task storage.

## Prerequisites

*   [Node.js](https://nodejs.org/) (v16 or later recommended)
*   [npm](https://www.npmjs.com/) (usually comes with Node.js)
*   [MongoDB](https://www.mongodb.com/) (Optional, if using database persistence)
*   [ngrok](https://ngrok.com/) or similar tunnelling service (Required for local development with Twilio webhooks)
*   API Keys for:
    *   OpenAI
    *   Google Maps Platform (Places API enabled)
    *   Twilio (Account SID, Auth Token, Twilio Phone Number)

## Setup

1.  **Clone the repository** (if applicable)
2.  **Navigate to the `backend` directory:**
    ```bash
    cd path/to/local-errand-assistant/backend
    ```
3.  **Install dependencies:**
    ```bash
    npm install
    ```
4.  **Create a `.env` file:** Copy the `.env.example` file to `.env`.
    ```bash
    cp .env.example .env
    ```
5.  **Configure `.env`:** Open the `.env` file and fill in your API keys, Twilio credentials, database URL (if using), and the `BASE_URL`.
    *   **`BASE_URL` is critical for Twilio callbacks.** During local development, start `ngrok` (`ngrok http 5001`) and use the `https` forwarding URL provided by ngrok as your `BASE_URL`.

## Running the Server

*   **Development Mode (with automatic restart using `nodemon`):**
    ```bash
    npm run dev
    ```
    *Ensure `ngrok` (or your public tunnel) is running and `BASE_URL` is correctly set in `.env`.*

*   **Production Mode:**
    ```bash
    npm start
    ```
    *Make sure `NODE_ENV=production` is set (or use a process manager like PM2). Ensure `BASE_URL` points to your actual public server address.*

## API Endpoints

*   `POST /api/errands`: Create a new errand task.
    *   Body: `{ "request": "User's natural language request", "location": { "lat": 40.7, "lng": -74.0 } }` (location optional)
*   `GET /api/errands/:taskId/status`: Get the status of a specific task.
*   `POST /api/errands/twilio/callback`: (Internal) Webhook endpoint for Twilio status updates.
*   `GET /`: Basic server running message.
*   `GET /health`: Health check endpoint.

## Environment Variables

See `.env.example` for a list of required and optional environment variables.

## TODO / Future Enhancements

*   Implement robust authentication/authorization.
*   Add more sophisticated conversational logic using Twilio `<Gather>` (speech/DTMF).
*   Integrate WebSockets for real-time frontend updates instead of polling.
*   Implement proper testing (unit, integration).
*   Improve error handling and resilience.
*   Add rate limiting.
*   Consider queueing for handling long-running tasks or high load.