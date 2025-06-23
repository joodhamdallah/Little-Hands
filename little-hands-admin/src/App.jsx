import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import AppLayout from './layout/AppLayout';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import Bookings from './pages/Bookings';
import ExpertPosts from './pages/ExpertPosts'; 
import Complaints from './pages/ComplaintsPage'; // make sure this path is correct

function App() {
  return (
    <Router>
      <Routes>
        <Route element={<AppLayout />}>
          <Route path="/" element={<Dashboard />} />
          <Route path="/users" element={<Users />} /> 
          <Route path="/bookings" element={<Bookings />} />
          <Route path="/posts" element={<ExpertPosts />} />
          <Route path="/complaints" element={<Complaints />} />

        </Route>
      </Routes>
    </Router>
  );
}

export default App;
