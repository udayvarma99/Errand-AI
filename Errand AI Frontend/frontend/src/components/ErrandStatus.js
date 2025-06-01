// frontend/src/components/ErrandStatus.js
// *** UPDATED to robustly display detailed results including taskStatus ***

import React from 'react';
import LoadingSpinner from './LoadingSpinner';

const ErrandStatus = ({ status: detailedMessageFromParent, result, error, isLoading }) => {
  // 'status' prop is renamed to 'detailedMessageFromParent' for clarity
  // 'result' prop is expected to be the full taskData object from the backend

  const renderResultDetails = () => {
    // If no result object (taskData) is available, don't render details
    if (!result) {
        // If still loading and no result, it's fine
        if (isLoading) return <p>Waiting for task details...</p>;
        // If not loading, no result, and no error, it's an odd state, maybe show nothing or idle message
        return null;
    }

    // Destructure all relevant fields from the result (taskData) object
    const {
        taskId,
        status: taskStatus, // This is the overall status from the backend Errand model
        confirmationStatus, // Specific to appointment confirmation
        details,            // Contains parsed request, selected place, etc.
        callOutcome,        // Contains final Twilio call status, DTMF, call errors
        error: taskLevelError, // Top-level error stored in the backend task object
        steps,              // Array of process steps with timestamps
        conversationLog     // Array of conversation turns
    } = result;

    // Get the most recent step for display
    const lastStep = steps && steps.length > 0 ? steps[steps.length - 1] : null;

    return (
      <>
        <h3>Task Progress & Details:</h3>

        {/* Display the overall taskStatus directly from the model */}
        {taskStatus && (
            <p><strong>Overall Task Status: <span style={{textTransform: 'capitalize'}}>{taskStatus.replace(/_/g, ' ')}</span></strong></p>
        )}

        {/* Display Appointment Confirmation Status if applicable */}
        {confirmationStatus && confirmationStatus !== 'pending' && (
            <p style={{ fontWeight: 'bold', color: confirmationStatus === 'confirmed' ? 'green' : 'red' }}>
                Appointment Outcome: {confirmationStatus.toUpperCase()}
            </p>
        )}

        {/* Display details of the last executed step */}
        {lastStep && (
            <p style={{fontSize: '0.95em', color: '#444'}}>
                Last Action ({new Date(lastStep.timestamp).toLocaleTimeString()}):
                <strong> {lastStep.step.replace(/_/g, ' ')}</strong>
                {lastStep.error ? <span style={{color: '#c0392b'}}> - Error: {lastStep.error}</span> : ''}
            </p>
        )}

        {/* Display selected place if available */}
        {details?.selectedPlace?.name && (
            <p style={{fontSize: '0.95em', color: '#444'}}>Contacting: {details.selectedPlace.name} ({details.selectedPlace.phone})</p>
        )}

        {/* Display Call Outcome from Twilio if the call has fully completed or failed */}
         {callOutcome && (callOutcome.finalStatus || callOutcome.dtmfInput || callOutcome.error) && (
            <div style={{marginTop: '10px', paddingTop: '10px', borderTop: '1px solid #f0f0f0'}}>
                <h4>Call Summary:</h4>
                {callOutcome.finalStatus && <p>Twilio Final Call Status: {callOutcome.finalStatus}</p>}
                {callOutcome.dtmfInput && <p>Keypad Input Received: {callOutcome.dtmfInput}</p>}
                 {callOutcome.error && <p style={{color: '#c0392b'}}>Call-Specific Error from Twilio: {callOutcome.error}</p>}
            </div>
         )}

        {/* Display any overall task-level error message from the backend */}
        {taskLevelError && <p className="status-error" style={{marginTop: '10px'}}>Task Error: {taskLevelError}</p>}

        {/* Optional: Display conversation log snippets if available */}
        {conversationLog && conversationLog.length > 0 && (
            <div style={{marginTop: '15px', paddingTop: '10px', borderTop: '1px solid #f0f0f0', maxHeight: '150px', overflowY: 'auto'}}>
                <h4>Conversation Snippets:</h4>
                {conversationLog.map((turn, index) => (
                    <p key={index} style={{margin: '3px 0', fontSize: '0.9em'}}>
                        <strong style={{textTransform: 'capitalize'}}>{turn.speaker}:</strong> {turn.text}
                    </p>
                ))}
            </div>
        )}

        {/* Always display Task ID for reference */}
        {taskId && <p style={{marginTop: '15px'}}><small>Task ID: {taskId}</small></p>}
      </>
    );
  };

  return (
    <div className="errand-status-container">
      {/* This 'status' prop is the user-facing detailedMessage from HomePage.js */}
      <span className="status-label">Current Update:</span>

      {/* Handle loading state */}
      {isLoading && !error && <LoadingSpinner />} {/* Show spinner if loading and no major submission error */}

      {/* Handle top-level submission error passed from HomePage */}
      {error && <p className="status-error">{error}</p>}

      {/* Display the main status message */}
      {!isLoading && !error && ( // Only show status message if not loading and no error
            <p className="status-message">
              {detailedMessageFromParent}
            </p>
      )}

      {/* Display detailed results if available AND no primary submission error */}
      {/* Also, don't show details if still in initial loading from a fresh submit */}
      {result && !error && (
        <div className="status-result">
            {renderResultDetails()}
        </div>
      )}

      {/* Message for when it's not loading, no error, but also no result yet */}
      {!isLoading && !error && !result && detailedMessageFromParent !== 'Waiting for your request...' && detailedMessageFromParent !== 'Connected. Ready for your errand.' && (
            <p>Processing your request... waiting for first update.</p>
      )}
    </div>
  );
};

export default ErrandStatus;