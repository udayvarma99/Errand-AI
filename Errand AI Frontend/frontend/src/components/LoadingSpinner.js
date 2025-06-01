// frontend/src/components/LoadingSpinner.js
// A simple CSS-based loading spinner component.

import React from 'react';
// CSS for this component should be in App.css or a dedicated CSS file

const LoadingSpinner = () => {
  // The actual spinner is created using CSS borders and animation
  // The CSS class 'loading-spinner' needs to be defined (e.g., in App.css)
  return <div className="loading-spinner" aria-label="Loading..."></div>;
};

export default LoadingSpinner;