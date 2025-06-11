import React from 'react';
import Sidebar from '../components/Sidebar';
import { Outlet } from 'react-router-dom';

const AppLayout = () => {
  return (
    <div style={{ display: 'flex', height: '100vh', backgroundColor: '#F5F7FA' }}>
      <Sidebar />
      <main style={{
        flex: 1,
        padding: '30px',
        overflowY: 'auto',
        fontFamily: 'Arial, sans-serif',
      }}>
        <Outlet />
      </main>
    </div>
  );
};

export default AppLayout;
