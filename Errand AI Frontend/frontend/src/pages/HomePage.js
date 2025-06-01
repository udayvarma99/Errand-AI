// frontend/src/pages/HomePage.js
// Main component for the Errand Assistant functionality.

import React, { useState, useEffect, useCallback, useRef } from 'react';
import io from 'socket.io-client'; // WebSocket client
import ErrandInput from '../components/ErrandInput'; // Input form component
import ErrandStatus from '../components/ErrandStatus'; // Status display component
// Import API functions, including the corrected getUserLocation
import { sendErrandRequest, getUserLocation } from '../services/api';
// Optional: Import Auth context if needed
// import { useAuth } from '../contexts/AuthContext';

// --- WebSocket URL Calculation ---
const SOCKET_URL = process.env.REACT_APP_API_URL ?
                    process.env.REACT_APP_API_URL.replace('/api', '') :
                    'http://localhost:5001'; // Fallback URL
// --------------------------------

// --- Terminal States Definition ---
const TERMINAL_TASK_STATES = [
    'appointment_confirmed', // If using full conversational AI
    'appointment_confirmed_dtmf', // If using DTMF for confirmation
    'appointment_declined', // If using full conversational AI
    'appointment_declined_dtmf', // If using DTMF
    'appointment_failed_negotiation', // AI couldn't book
    'appointment_failed_no_dtmf', // DTMF gather timed out
    'appointment_failed_input', // Generic input failure for conversational AI
    'sms_notification_sent',
    'sms_notification_failed',
    'call_completed',
    'call_completed_with_input', // If call completed after some interaction
    'call_failed_busy',
    'call_failed_no_answer',
    'call_canceled',
    'call_failed',
    'completed', // For tasks that don't involve a call or complete differently
    'failed'     // General task failure (parsing, maps, etc.)
].map(s => s.toLowerCase());
// ----------------------------------

console.log("HomePage: Attempting to connect WebSocket to calculated URL:", SOCKET_URL);

function HomePage() {
  // --- State Variables ---
  const [requestText, setRequestText] = useState('');
  const [userPhoneNumber, setUserPhoneNumber] = useState('');
  const [status, setStatus] = useState('Idle'); // Internal status from backend
  const [detailedMessage, setDetailedMessage] = useState('Enter your errand request below.');
  const [result, setResult] = useState(null); // Stores full task data from backend
  const [error, setError] = useState(null);   // For submission or major errors
  const [isLoading, setIsLoading] = useState(false);
  const [currentTaskId, setCurrentTaskId] = useState(null);
  const [userCoords, setUserCoords] = useState(null); // { lat, lng }
  const [locationError, setLocationError] = useState(null); // Error from geolocation attempt

  const socketRef = useRef(null);
  // const { user } = useAuth(); // Uncomment if displaying user info

  // --- WebSocket Connection and Listener Effect ---
  useEffect(() => {
    if (!SOCKET_URL || !SOCKET_URL.startsWith('http')) {
        console.error("HomePage: Invalid SOCKET_URL derived:", SOCKET_URL);
        setDetailedMessage("Error: Cannot connect to update server.");
        return; // Don't attempt to connect
    }

    console.log(`HomePage Effect: Initializing WebSocket connection to ${SOCKET_URL}`);
    socketRef.current = io(SOCKET_URL, {
        reconnectionAttempts: 5,
        reconnectionDelay: 1000,
        transports: ['websocket', 'polling'] // Allow fallback
    });
    const socket = socketRef.current;

    const handleConnect = () => {
        console.log('HomePage WebSocket connected:', socket.id);
        // Update UI message only if truly idle to avoid overwriting task messages
        if (status === 'Idle' && !currentTaskId) {
            setDetailedMessage('Connected. Ready for your errand.');
        }
        // If a task was active during a disconnect, try to rejoin its room
        if (currentTaskId) {
            console.log(`HomePage: Re-joining WebSocket room on connect/reconnect: ${currentTaskId}`);
            socket.emit('join_task_room', currentTaskId);
        }
    };

    const handleDisconnect = (reason) => {
        console.log('HomePage WebSocket disconnected:', reason);
        if (!TERMINAL_TASK_STATES.includes(status.toLowerCase()) && currentTaskId) {
            setDetailedMessage("Connection to update server lost. Attempting to reconnect...");
        } else if (status === 'Idle' || !currentTaskId) {
            setDetailedMessage("Connection lost. Please check internet or refresh.");
        }
    };

    const handleConnectError = (err) => {
        console.error('HomePage WebSocket connection error:', err);
        setDetailedMessage(`Connection Error: ${err.message}. Real-time updates may not work.`);
        setError(`WebSocket Connection Error: ${err.message}`); // Set a general error
    };

    // --- Main Listener for Task Updates from Backend ---
    const handleTaskUpdate = (data) => {
        console.log('HomePage WS task_update received:', data);
        // Only process updates for the task we are currently tracking
        if (data && data.taskId === currentTaskId) {
            const receivedStatus = data.status?.toLowerCase() || 'unknown_status';
            const taskData = data.taskData || {}; // The full errand object from backend

            console.log(`HomePage Processing update for task ${currentTaskId}, Received Status: ${receivedStatus}`);

            // Construct a user-friendly message based on the status
            let userMsg = data.message || `Task is now ${receivedStatus.replace(/_/g, ' ')}.`;
            // You can add more specific messages based on receivedStatus here if needed
            // Example: if (receivedStatus === 'awaiting_human_response') userMsg = `AI: "${taskData.details?.lastAiResponse}"`;
            setDetailedMessage(userMsg);

            setStatus(receivedStatus); // Update internal status tracker
            setError(taskData.error || data.error || null); // Update with any error from backend
            setResult(taskData); // Store the latest full task data

            // Check if this is a terminal state to stop loading indicator
            const isTerminal = TERMINAL_TASK_STATES.includes(receivedStatus);
            console.log(`HomePage Status: '${receivedStatus}', Is terminal? ${isTerminal}`);

            if (isTerminal) {
                console.log(`HomePage >>> Terminal state (${receivedStatus}) reached. Stopping loading indicator.`);
                setIsLoading(false);
            } else {
                // If not terminal but a task is active, ensure loading is true
                if(currentTaskId) setIsLoading(true);
            }
        } else if (data) {
             console.log(`HomePage Received task update for different/old task (${data.taskId}), ignoring.`);
        }
    };

    // Attach event listeners to the socket
    socket.on('connect', handleConnect);
    socket.on('disconnect', handleDisconnect);
    socket.on('connect_error', handleConnectError);
    socket.on('task_update', handleTaskUpdate);

    // Cleanup function: Remove listeners and disconnect socket when component unmounts
    return () => {
        console.log('HomePage: Cleaning up WebSocket connection...');
        socket.off('connect', handleConnect);
        socket.off('disconnect', handleDisconnect);
        socket.off('connect_error', handleConnectError);
        socket.off('task_update', handleTaskUpdate);
        if (socket.connected) {
            socket.disconnect();
        }
        socketRef.current = null;
    };
  }, [currentTaskId, status]); // Dependencies for the effect


  // --- Event Handlers for Inputs ---
  const handleInputChange = useCallback((event) => setRequestText(event.target.value), []);
  const handlePhoneNumberChange = useCallback((event) => setUserPhoneNumber(event.target.value), []);

  // --- Handler for "Use My Location" Button ---
  const handleGetLocation = useCallback(async () => {
      console.log("HomePage: handleGetLocation called!");
      setLocationError(null); // Clear previous errors
      setUserCoords(null);    // Clear previous coords
      setIsLoading(true);     // Set loading state for this action
      setStatus("Getting location..."); // Update internal status
      setDetailedMessage("Attempting to get your current location..."); // Update UI message

      try {
          console.log("HomePage: Attempting to call getUserLocation() from api.js...");
          const coords = await getUserLocation(); // Call the async function

          // *** CRITICAL CHECK for valid coordinates object ***
          if (coords && typeof coords.lat === 'number' && typeof coords.lng === 'number') {
              console.log("HomePage: getUserLocation success, valid coords received:", coords);
              setUserCoords(coords);           // Update state with coordinates
              setStatus("Location acquired");
              setDetailedMessage(`Location acquired: ${coords.lat.toFixed(4)}, ${coords.lng.toFixed(4)}. You can include this in your request or type a location.`);
              setLocationError(null);          // Clear any previous location error
          } else {
              // This case handles if getUserLocation resolves but with an invalid/empty coords object
              console.error("HomePage: getUserLocation resolved but coords are invalid or undefined:", coords);
              throw new Error("Failed to retrieve valid coordinate data from browser.");
          }
          // **************************************************

      } catch (locError) {
          // This catch block handles rejections from getUserLocation OR the error thrown above
          console.error("HomePage: handleGetLocation Error caught:", locError);
          setLocationError(locError.message || "An unknown error occurred while fetching location.");
          setStatus("Location Error");
          setDetailedMessage(`Could not get location: ${locError.message || "Unknown error"}`);
          setUserCoords(null);           // Ensure coords are null on any error
      } finally {
          console.log("HomePage: handleGetLocation finished.");
          setIsLoading(false); // Always stop loading indicator for this specific action
      }
  }, []); // Empty dependency array is correct

  // --- Handler for "Submit Errand" Button ---
  const handleErrandSubmit = useCallback(async () => {
      const trimmedRequest = requestText.trim();
      const trimmedPhone = userPhoneNumber.trim();

      // Frontend Validation
      if (!trimmedRequest) { setDetailedMessage("Please enter an errand request."); setError("Errand request is empty."); return; }
      if (!trimmedPhone || !/^\+?[1-9]\d{7,14}$/.test(trimmedPhone.replace(/[^\d+]/g, ''))) {
           setDetailedMessage("Please enter a valid phone number in E.164 format (e.g., +15551234567) for confirmation SMS."); setError("Invalid phone number format."); return;
      }

      console.log("--- Submitting New Errand ---");
      setIsLoading(true); // <<< Start main loading indicator for errand submission >>>
      setStatus('Submitting...');
      setDetailedMessage('Sending your errand request to the assistant...');
      setError(null);       // Clear previous general errors
      setLocationError(null); // Clear previous location errors
      setResult(null);      // Clear previous results
      setCurrentTaskId(null); // Clear previous task ID

      try {
          console.log("HomePage: Submitting errand with userCoords:", userCoords);
          const response = await sendErrandRequest(trimmedRequest, trimmedPhone, userCoords);
          console.log("HomePage: Initial backend response upon submission:", response);

          setCurrentTaskId(response.taskId || null); // Set new task ID to start tracking updates

          // Handle initial response from backend
          if (response.status === 'Completed' && response.places) {
              console.log("HomePage: Task completed via initial HTTP response (e.g., find-only).");
              setStatus('Completed');
              setDetailedMessage(response.message || "Found places successfully.");
              setResult(response);
              setIsLoading(false); // Stop loading immediately for direct completion
          } else if (response.initialStatus || response.status) { // Call initiated or backend is processing
              console.log("HomePage: Interactive call/task initiated. Waiting for WebSocket updates.");
              setStatus(response.initialStatus || response.status || 'Task Initiated');
              setDetailedMessage(response.message || 'Task accepted, initiating actions...');
              setResult(response); // Store initial data (taskId, placeName etc.)
               if (response.taskId && socketRef.current && socketRef.current.connected) {
                  console.log(`HomePage Submitting: Attempting to join WebSocket room: ${response.taskId}`);
                  socketRef.current.emit('join_task_room', response.taskId);
               } else if (response.taskId) {
                  console.warn("HomePage Submitting: Socket not connected at submission time, connect handler should attempt join.");
               }
               // isLoading remains true; WebSocket updates will handle setting it to false when a terminal state is reached
          } else {
              console.warn("HomePage: Unexpected initial response structure from backend:", response);
              setStatus('Unknown Backend State');
              setDetailedMessage('Received an unusual initial response from the backend.');
              setResult(response);
              setIsLoading(true); // Keep loading, wait for WebSocket to clarify
          }

      } catch (err) {
          console.error("HomePage: Errand submission failed (HTTP request error):", err);
          setError(err.message);
          setStatus('Error');
          setDetailedMessage(`Submission failed: ${err.message}`);
          setIsLoading(false); // Stop loading on submission error
          setCurrentTaskId(null);
      }
  }, [requestText, userPhoneNumber, userCoords, currentTaskId]); // Added currentTaskId to deps as it's used in WS re-join
                                                                // This might re-trigger the effect if not careful,
                                                                // but the effect logic itself handles currentTaskId for re-joining rooms.
                                                                // Consider if 'status' should also be a dependency for the effect.

  // --- Render Homepage UI ---
  return (
    <div> {/* Main container for HomePage content */}
      {/* Optional: Display user info if AuthContext is used */}
      {/* {user && <p>Welcome, {user.email}!</p>} */}

      {userCoords && (
          <p className="location-info" style={{color: '#27ae60', fontSize: '0.9em', marginBottom: '15px'}}>
              Using location: {userCoords.lat.toFixed(4)}, {userCoords.lng.toFixed(4)}
          </p>
      )}

      <ErrandInput
        value={requestText}
        onChange={handleInputChange}
        userPhoneNumber={userPhoneNumber}
        onPhoneNumberChange={handlePhoneNumberChange}
        onSubmit={handleErrandSubmit}
        disabled={isLoading}
        onGetLocation={handleGetLocation} // Pass the correctly implemented handler
        locationError={locationError} // Pass the error state
      />

      <ErrandStatus
        status={detailedMessage} // User-facing message reflecting current state
        result={result} // Full taskData object for detailed display
        error={error}   // General submission errors
        isLoading={isLoading} // Controls the spinner within ErrandStatus
      />

      {/* Display Conversation Log if available in the result */}
      {result?.conversationLog && result.conversationLog.length > 0 && (
        <div className="conversation-log-container" style={{
            marginTop: '20px', textAlign: 'left',
            maxHeight: '200px', overflowY: 'auto',
            border: '1px solid #ddd', padding: '10px',
            background: '#f9f9f9', borderRadius: '4px'
        }}>
            <h4>Conversation Log:</h4>
            {result.conversationLog.map((turn, index) => (
                <p key={index} className="conversation-turn" style={{
                    margin: '5px 0', fontSize: '0.9em',
                    paddingBottom: '5px',
                    borderBottom: index < result.conversationLog.length - 1 ? '1px dashed #eee' : 'none'
                }}>
                    <strong style={{
                        textTransform: 'capitalize',
                        color: turn.speaker === 'ai' ? '#3498db' : '#2ecc71'
                    }}>
                        {turn.speaker}:
                    </strong> {turn.text}
                </p>
            ))}
        </div>
     )}
    </div>
  );
}

export default HomePage;