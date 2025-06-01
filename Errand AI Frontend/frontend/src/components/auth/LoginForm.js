// frontend/src/components/auth/LoginForm.js
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom'; // For redirection and linking
import { useAuth } from '../../contexts/AuthContext'; // Use the auth context

const LoginForm = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const { login, loading, error } = useAuth(); // Get login function and state from context
    const navigate = useNavigate(); // Hook for programmatic navigation

    const handleSubmit = async (e) => {
        e.preventDefault(); // Prevent default form submission
        const success = await login(email, password); // Call login action from context
        if (success) {
            navigate('/'); // Redirect to home page on successful login
        }
        // Error state is managed by AuthContext and can be displayed
    };

    return (
        <div className="auth-form-container">
            <h2>Login</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="login-email">Email</label>
                    <input
                        type="email"
                        id="login-email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        disabled={loading}
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="login-password">Password</label>
                    <input
                        type="password"
                        id="login-password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                        disabled={loading}
                    />
                </div>
                {error && <p className="error-message">{error}</p>} {/* Display login errors */}
                <button type="submit" disabled={loading}>
                    {loading ? 'Logging In...' : 'Login'}
                </button>
            </form>
            <p className="auth-switch-link">
                Don't have an account? <Link to="/register">Sign Up</Link>
            </p>
        </div>
    );
};

export default LoginForm;