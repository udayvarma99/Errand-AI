// frontend/src/index.js
// Main entry point for the React application

import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom'; // For routing capabilities
import { AuthProvider } from './contexts/AuthContext'; // Context provider for authentication state
import './index.css'; // Optional global styles
import App from './App'; // The main App component containing routes

// Get the root DOM element
const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('Failed to find the root element'); // Ensure root exists

// Create a React root
const root = ReactDOM.createRoot(rootElement);

// Render the application
root.render(
  <React.StrictMode> {/* Helps identify potential problems */}
    <BrowserRouter> {/* Enables routing throughout the app */}
      <AuthProvider> {/* Provides authentication state to the entire app */}
        <App /> {/* The main component containing page routes */}
      </AuthProvider>
    </BrowserRouter>
  </React.StrictMode>
);