// frontend/src/App.js
// *** THIS IS THE MAIN ROUTER SETUP FOR THE APPLICATION ***

import React from 'react';
// Import necessary components from react-router-dom for routing
import { Routes, Route } from 'react-router-dom';

// Import Page components
import HomePage from './pages/HomePage';          // Page containing the actual Errand Assistant UI
import LoginPage from './pages/LoginPage';        // Page containing the LoginForm component
import RegisterPage from './pages/RegisterPage';  // Page containing the RegisterForm component

// Import Layout and Helper components
import Navbar from './components/layout/Navbar';    // Navigation bar component
import PrivateRoute from './components/layout/PrivateRoute'; // Component to protect routes that require login
import LoadingSpinner from './components/LoadingSpinner'; // Spinner for loading states

// Import the Auth Context hook to check initial loading state
import { useAuth } from './contexts/AuthContext';

// Import main CSS
import './App.css';

function App() {
    // Get the initial loading state from the authentication context.
    // This is true while the context checks if a user is already logged in
    // (e.g., by verifying a token found in localStorage).
    const { loading: authLoading } = useAuth(); // Rename to avoid potential naming conflicts

    // While the AuthProvider is checking the initial authentication status,
    // display a loading indicator to prevent rendering routes prematurely.
    if (authLoading) {
         return (
            // Basic centered loading display covering the viewport height
            <div className="App" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '100vh' }}>
                <LoadingSpinner />
            </div>
         );
    }

    // Once initial auth check is complete, render the main application layout and routes
    return (
        <div className="App"> {/* Main container */}
            {/* Navbar is rendered outside the Routes, so it appears on all pages */}
            <Navbar />

            {/* Main content area where routed pages will be displayed */}
            <main className="main-content"> {/* Class for potential styling */}
                <Routes> {/* Defines the routing configuration */}

                    {/* Public Routes: Accessible whether logged in or not */}
                    <Route path="/login" element={<LoginPage />} />
                    <Route path="/register" element={<RegisterPage />} />

                    {/* Private Routes: Wrapped by PrivateRoute component */}
                    {/* The PrivateRoute component will check if the user is authenticated. */}
                    {/* If yes, it renders the nested Route's element (via <Outlet />). */}
                    {/* If no, it redirects the user to the /login page. */}
                    <Route path="/" element={<PrivateRoute />}>
                        {/* The 'index' route matches the parent path exactly ("/") */}
                        <Route index element={<HomePage />} />
                        {/* Add any other pages that require login as nested routes here */}
                        {/* Example: <Route path="profile" element={<UserProfilePage />} /> */}
                    </Route>

                    {/* Catch-all Route: Renders if no other route matches */}
                    <Route path="*" element={<NotFoundPage />} />

                </Routes>
            </main>

            {/* Optional Footer could go here */}
            {/* <footer className="footer">© 2025 Errand AI</footer> */}
        </div>
    );
}

// Simple component for the 404 page (can be moved to its own file in src/pages/)
const NotFoundPage = () => (
    <div style={{ textAlign: 'center', marginTop: '50px' }}>
        <h2>404 - Page Not Found</h2>
        <p>Sorry, the page you are looking for doesn't exist.</p>
    </div>
);

// Export the App component to be used in index.js
export default App;