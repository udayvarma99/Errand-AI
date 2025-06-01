// frontend/src/components/layout/PrivateRoute.js
import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';
import LoadingSpinner from '../LoadingSpinner'; // Use your spinner

const PrivateRoute = () => {
    const { isAuthenticated, loading } = useAuth();

    if (loading) {
        // Show loading indicator while auth state is being checked
        return <LoadingSpinner />;
    }

    // If authenticated, render the child component (Outlet)
    // Otherwise, redirect to the login page
    return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />;
};

export default PrivateRoute;