// frontend/src/components/layout/Navbar.js
// Navigation bar component for the application.

import React from 'react';
import { Link, useNavigate } from 'react-router-dom'; // For navigation links and programmatic navigation
import { useAuth } from '../../contexts/AuthContext'; // Hook to access authentication state and functions

const Navbar = () => {
    // Get authentication state and functions from the AuthContext
    const { isAuthenticated, user, logout, loading: authLoading } = useAuth(); // Destructure user and loading
    const navigate = useNavigate(); // Hook for redirecting after logout

    // Handler for the logout button
    const handleLogout = () => {
        logout(); // Call the logout function from AuthContext
        navigate('/login'); // Redirect the user to the login page after logout
    };

    return (
        <nav className="navbar"> {/* Main navbar container */}
            <div className="navbar-brand">
                {/* Link to the homepage */}
                <Link to="/">Errand AI</Link>
            </div>

            {/* Links shown in the navbar */}
            <ul className="navbar-links">
                {/* Show a loading indicator while auth state is being determined */}
                {authLoading ? (
                    <li>Loading User...</li>
                ) : isAuthenticated && user ? ( // Check if user object exists
                    // If authenticated and user data is available
                    <>
                        {/* --- USE THE 'user' VARIABLE HERE --- */}
                        {/* Display user's email or a welcome message */}
                        <li className="navbar-user-greeting">
                            {/* You can choose to display user.email or a generic greeting */}
                            <span>Welcome, {user.email || 'User'}!</span> {/* Fallback to 'User' if email isn't there */}
                        </li>
                        {/* ------------------------------------ */}
                        <li>
                            <button onClick={handleLogout} className="logout-button">
                                Logout
                            </button>
                        </li>
                    </>
                ) : (
                    // If not authenticated
                    <>
                        <li><Link to="/login">Login</Link></li>
                        <li><Link to="/register">Sign Up</Link></li>
                    </>
                )}
            </ul>
        </nav>
    );
};

export default Navbar;