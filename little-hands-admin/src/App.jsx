import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AppLayout from './layout/AppLayout';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Bookings from './pages/Bookings';
import ExpertPosts from './pages/ExpertPosts'; 

function App() {
  return (
    <Router>
      <Routes>
        <Route element={<AppLayout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/users" element={<Users />} /> 
          <Route path="/bookings" element={<Bookings />} />
          <Route path="/posts" element={<ExpertPosts />} />

        </Route>
      </Routes>
    </Router>
  );
}

export default App;
