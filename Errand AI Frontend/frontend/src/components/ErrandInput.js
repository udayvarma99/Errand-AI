// frontend/src/components/ErrandInput.js
// Component for user inputs: errand request, phone number, and action buttons.

import React from 'react';

// Props expected from the parent component (HomePage.js)
const ErrandInput = ({
    value,                // Current text in the main errand request textarea
    onChange,             // Function to call when textarea content changes (updates requestText state)
    onSubmit,             // Function to call when the 'Submit Errand' button is clicked
    disabled,             // Boolean to disable inputs/buttons (typically while isLoading is true)
    onGetLocation,        // Function to call when the 'Use My Location' button is clicked
    locationError,        // String containing any error message from the last location attempt
    userPhoneNumber,      // Current text in the phone number input
    onPhoneNumberChange   // Function to call when phone number input changes (updates userPhoneNumber state)
}) => {

  // Basic check to enable/disable submit button based on required fields
  const isSubmitDisabled = disabled || !value?.trim() || !userPhoneNumber?.trim();

  return (
    <div className="errand-input-container"> {/* Styles for this container in App.css */}

      {/* Main Errand Request Text Area */}
      <textarea
        value={value}
        onChange={onChange}
        placeholder="Enter your errand request (e.g., 'Book a dentist appointment for Tuesday 3pm near downtown')"
        disabled={disabled}
        rows={4} // Initial rows, can be resized vertically
        aria-label="Errand request input"
        required // Indicate field is required (though validation is in parent)
      />

      {/* Phone Number Input */}
      <input
        type="tel" // Use 'tel' type for semantic meaning and mobile keyboards
        value={userPhoneNumber}
        onChange={onPhoneNumberChange}
        placeholder="Your Phone # for SMS Confirmation (e.g., +15551234567)"
        disabled={disabled}
        required // HTML5 validation, main validation in parent's submit handler
        style={{ // Basic inline styles for quick setup
          width: 'calc(100% - 30px)', // Adjust width to roughly match textarea with padding
          padding: '10px 15px',
          marginTop: '10px',
          marginBottom: '15px',
          border: '1px solid #dcdcdc',
          borderRadius: '4px',
          fontSize: '1rem',
          fontFamily: 'inherit'
         }}
        aria-label="Your phone number for SMS confirmation"
      />

      {/* Display Location Fetching Errors */}
      {locationError && (
        <p className="location-error-message" style={{ color: 'orange', fontSize: '0.9em', marginTop: '-10px', marginBottom: '10px', textAlign: 'left' }}>
            {locationError}
        </p>
      )}

      {/* Container for Action Buttons */}
      <div className="action-buttons">
        {/* Submit Button */}
        <button
          onClick={onSubmit}
          disabled={isSubmitDisabled} // Disable based on validation state
          title={isSubmitDisabled ? "Please enter request and phone number" : "Submit your errand request"}
        >
            {disabled ? 'Processing...' : 'Submit Errand'}
        </button>

        {/* Use My Location Button (conditionally rendered) */}
        {/* Render only if the onGetLocation function is provided as a prop */}
        {typeof onGetLocation === 'function' && (
           <button
               type="button" // Good practice for non-submit buttons in a form context
               onClick={onGetLocation} // Attach the handler passed via props
               disabled={disabled} // Disable while other actions are processing
               style={{marginLeft: '10px', backgroundColor: '#2ecc71', color: 'white'}} // Simple styling
               title="Attempt to use your browser's current location"
              >
                Use My Location
            </button>
         )}
      </div>
    </div>
  );
};

export default ErrandInput;