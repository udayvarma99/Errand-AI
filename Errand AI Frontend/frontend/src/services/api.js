// frontend/src/services/api.js
import axios from 'axios';

// --- Get Base URL ---
const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001/api';
// --------------------

// --- Create Axios Instance ---
const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json'
    }
});
// ---------------------------

// --- Axios Request Interceptor ---
// This function runs before each request using the 'api' instance.
api.interceptors.request.use(
    (config) => {
        // Get token from localStorage (or your chosen storage)
        const token = localStorage.getItem('authToken'); // Use a consistent key name
        if (token) {
            // If token exists, add it to the Authorization header
            config.headers['Authorization'] = `Bearer ${token}`;
        } else {
            // Optional: Remove Authorization header if no token exists
            delete config.headers['Authorization'];
        }
        return config; // Return the modified config
    },
    (error) => {
        // Handle request configuration errors
        console.error("Axios request interceptor error:", error);
        return Promise.reject(error);
    }
);
// -------------------------------

// --- API Functions ---

// AUTH Functions (Using base axios or the instance depending on need)
export const loginUser = async (email, password) => {
    try {
        // Login doesn't need the token initially, can use base axios or instance
        const response = await axios.post(`${API_BASE_URL}/auth/login`, { email, password });
        return response.data; // { success: true, token, user }
    } catch (error) {
        console.error("Login API Error:", error.response?.data || error.message);
        throw new Error(error.response?.data?.message || 'Login failed');
    }
};

export const registerUser = async (email, password) => {
    try {
        const response = await axios.post(`${API_BASE_URL}/auth/register`, { email, password });
        return response.data; // { success: true, token, user }
    } catch (error) {
        console.error("Register API Error:", error.response?.data || error.message);
        throw new Error(error.response?.data?.message || 'Registration failed');
    }
};

export const getLoggedInUser = async () => {
    try {
        // MUST use the 'api' instance to include the Authorization header
        const response = await api.get(`/auth/me`);
        return response.data; // { success: true, user }
    } catch (error) {
        // Don't log generic 'Not authorized' here, let the caller handle it
        if (error.response?.status !== 401) {
             console.error("Get User API Error:", error.response?.data || error.message);
        }
        throw new Error(error.response?.data?.message || 'Failed to fetch user');
    }
};

// ERRAND Functions (These NEED the token, so use the 'api' instance)
export const sendErrandRequest = async (requestText, userPhoneNumber, location = null) => {
    try {
        const payload = { request: requestText, userPhoneNumber, location };
        const response = await api.post('/errands', payload); // Use 'api' instance
        return response.data;
    } catch (error) {
        console.error("Send Errand API Error:", error.response?.data || error.message);
        throw new Error(error.response?.data?.message || 'Failed to submit errand');
    }
};

export const getErrandStatus = async (taskId) => {
    if (!taskId) throw new Error("Task ID required");
    try {
        const response = await api.get(`/errands/${taskId}/status`); // Use 'api' instance
        return response.data;
    } catch (error) {
        console.error(`Get Status API Error for ${taskId}:`, error.response?.data || error.message);
        throw new Error(error.response?.data?.message || 'Failed to get errand status');
    }
};

// Geolocation (no changes needed)
export const getUserLocation = () => { /* ... existing code ... */ };

// Export the configured instance if needed elsewhere, though usually not
// export default api;