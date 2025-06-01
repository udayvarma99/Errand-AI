// frontend/src/components/auth/RegisterForm.js
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const RegisterForm = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [localError, setLocalError] = useState(''); // For password mismatch etc.
    const { register, loading, error: authError } = useAuth(); // Use context
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        setLocalError(''); // Clear local errors
        if (password !== confirmPassword) {
            setLocalError('Passwords do not match');
            return;
        }
        if (password.length < 6) {
             setLocalError('Password must be at least 6 characters');
            return;
        }

        const success = await register(email, password);
        if (success) {
            navigate('/'); // Redirect to home on success
        }
        // Auth error (like user exists) is handled by authError state
    };

    return (
        <div className="auth-form-container">
            <h2>Sign Up</h2>
            <form onSubmit={handleSubmit}>
                <div className="form-group">
                    <label htmlFor="register-email">Email</label>
                    <input
                        type="email"
                        id="register-email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                        disabled={loading}
                    />
                </div>
                <div className="form-group">
                    <label htmlFor="register-password">Password</label>
                    <input
                        type="password"
                        id="register-password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                        minLength="6"
                        disabled={loading}
                    />
                </div>
                 <div className="form-group">
                    <label htmlFor="confirm-password">Confirm Password</label>
                    <input
                        type="password"
                        id="confirm-password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        required
                        minLength="6"
                        disabled={loading}
                    />
                </div>
                {localError && <p className="error-message">{localError}</p>}
                {authError && <p className="error-message">{authError}</p>}
                <button type="submit" disabled={loading}>
                    {loading ? 'Signing Up...' : 'Sign Up'}
                </button>
            </form>
             <p className="auth-switch-link">
                Already have an account? <Link to="/login">Login</Link>
            </p>
        </div>
    );
};

export default RegisterForm;