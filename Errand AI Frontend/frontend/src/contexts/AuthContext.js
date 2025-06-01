// frontend/src/contexts/AuthContext.js
import React, { createContext, useState, useEffect, useContext, useCallback } from 'react';
import { loginUser, registerUser, getLoggedInUser } from '../services/api'; // Use API functions
import LoadingSpinner from '../components/LoadingSpinner'; // <<< IMPORT ADDED HERE

// Create Context: Provides a way to pass data through the component tree without props drilling
const AuthContext = createContext(null);

// Custom Hook: Simplifies using the Auth Context in components
export const useAuth = () => {
    return useContext(AuthContext);
};

// Provider Component: Wraps the application parts that need auth state
// It holds the state and provides functions to modify it
export const AuthProvider = ({ children }) => {
    // State for authentication details
    const [authState, setAuthState] = useState({
        token: localStorage.getItem('authToken') || null, // Load token from storage on initial load
        isAuthenticated: null, // null = checking, false = not auth, true = auth
        user: null,            // Logged-in user details
        loading: true,         // Start in loading state while checking token validity
        error: null,           // Stores authentication-related errors
    });

    // --- Effect to Load User on Initial Mount or Token Change ---
    useEffect(() => {
        const loadUser = async () => {
            // Get token from state (which got it from localStorage initially)
            const currentToken = authState.token;

            if (currentToken) {
                 console.log("AuthContext: Token exists, attempting to load user...");
                 // Keep loading true while fetching user, clear previous errors
                 setAuthState(prev => ({ ...prev, loading: true, error: null }));
                 try {
                    // getLoggedInUser uses the axios interceptor which automatically adds the token header
                    const data = await getLoggedInUser(); // Calls GET /api/auth/me

                    if (data.success && data.user) {
                        console.log("AuthContext: User loaded successfully", data.user);
                        // Successfully authenticated
                        setAuthState({
                            token: currentToken,
                            isAuthenticated: true,
                            user: data.user,
                            loading: false,
                            error: null,
                        });
                    } else {
                         // Backend didn't return expected data structure
                         console.error("AuthContext: Invalid user data received from /auth/me");
                         throw new Error('Invalid user data received');
                    }
                } catch (error) {
                     // Token likely invalid or expired (API returns 401, caught by api.js)
                     console.error("AuthContext: Failed to load user with token.", error.message);
                     localStorage.removeItem('authToken'); // Remove the invalid token
                     setAuthState({
                        token: null,
                        isAuthenticated: false,
                        user: null,
                        loading: false,
                        error: 'Your session may have expired. Please log in again.', // User-friendly error
                     });
                }
            } else {
                 console.log("AuthContext: No token, setting as unauthenticated.");
                 // No token found, definitely not authenticated
                 setAuthState({
                    token: null,
                    isAuthenticated: false,
                    user: null,
                    loading: false,
                    error: null,
                 });
            }
        };

        loadUser();
    // React wants authState.token in dependency array. If loadUser modifies the token (e.g., on error),
    // it *could* cause a loop, but our logic prevents that by only running loadUser if token *exists*.
    // If you see infinite loops, you might need more complex state management or effect dependencies.
    }, [authState.token]);

    // --- Login Action ---
    const login = useCallback(async (email, password) => {
        setAuthState(prev => ({ ...prev, loading: true, error: null })); // Set loading, clear error
        try {
            const data = await loginUser(email, password); // Call API function
            if (data.success && data.token && data.user) {
                localStorage.setItem('authToken', data.token); // Store token
                // Update state - this will trigger the useEffect above to potentially re-verify, but we already have user data
                setAuthState({
                    token: data.token,
                    isAuthenticated: true,
                    user: data.user,
                    loading: false,
                    error: null,
                });
                console.log("AuthContext: Login successful.");
                return true; // Indicate success to the form
            } else {
                 // Should ideally not happen if API throws error, but handle defensively
                 throw new Error(data.message || 'Login failed: Invalid response');
            }
        } catch (error) {
            console.error("Login action error:", error.message);
            // Keep token null/previous value, set error message from API
             setAuthState(prev => ({
                ...prev, // Keep previous token state, don't clear it on failed login attempt
                isAuthenticated: false,
                user: null,
                loading: false,
                error: error.message || 'Login failed.',
             }));
             return false; // Indicate failure
        }
    }, []); // useCallback with empty dependency array

    // --- Register Action ---
    const register = useCallback(async (email, password) => {
        setAuthState(prev => ({ ...prev, loading: true, error: null }));
        try {
            const data = await registerUser(email, password);
             if (data.success && data.token && data.user) {
                localStorage.setItem('authToken', data.token);
                // Set state - triggers useEffect
                setAuthState({
                    token: data.token,
                    isAuthenticated: true,
                    user: data.user,
                    loading: false,
                    error: null,
                });
                 console.log("AuthContext: Registration successful.");
                 return true;
            } else {
                 throw new Error(data.message || 'Registration failed: Invalid response');
            }
        } catch (error) {
            console.error("Register action error:", error.message);
             setAuthState(prev => ({
                ...prev,
                isAuthenticated: false,
                user: null,
                loading: false,
                error: error.message || 'Registration failed.',
             }));
             return false;
        }
    }, []); // useCallback with empty dependency array

    // --- Logout Action ---
    const logout = useCallback(() => {
        console.log("AuthContext: Logging out...");
        localStorage.removeItem('authToken');
        setAuthState({ // Reset state completely
            token: null,
            isAuthenticated: false,
            user: null,
            loading: false,
            error: null,
        });
        // Navigation happens in the component calling logout (e.g., Navbar)
    }, []); // useCallback with empty dependency array

    // --- Value provided by the context ---
    // Includes the state properties and the action functions
    const value = {
        token: authState.token,
        isAuthenticated: authState.isAuthenticated,
        user: authState.user,
        loading: authState.loading,
        error: authState.error,
        login,
        register,
        logout,
    };

    // Render the provider, passing the value down
    return (
        <AuthContext.Provider value={value}>
            {/* Show loading spinner only while initially checking auth status */}
            {/* Once loading is false, render children (the rest of the app) */}
            {authState.loading ? <LoadingSpinner /> : children}
        </AuthContext.Provider>
    );
};