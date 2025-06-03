import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Dashboard, People, EventNote, PostAdd } from '@mui/icons-material';

const Sidebar = () => {
  const location = useLocation();

  const links = [
    { to: '/', label: 'Dashboard', icon: <Dashboard fontSize="small" /> },
    { to: '/users', label: 'Users', icon: <People fontSize="small" /> },
    { to: '/bookings', label: 'Bookings', icon: <EventNote fontSize="small" /> },
    { to: '/posts', label: 'Expert Posts', icon: <PostAdd fontSize="small" /> },
  ];

  return (
    <div style={{
      width: '240px',
      background: 'linear-gradient(135deg, #FF600A, #ff884d)',
      color: 'white',
      padding: '20px',
      display: 'flex',
      flexDirection: 'column',
      boxShadow: '2px 0 8px rgba(0,0,0,0.1)',
    }}>
      <h2 style={{
        marginBottom: '40px',
        fontFamily: 'NotoSansArabic',
        fontWeight: 'bold',
        fontSize: '22px'
      }}>لوحة التحكم</h2>

      {links.map(link => {
        const active = location.pathname === link.to;
        return (
          <Link
            key={link.to}
            to={link.to}
            style={{
              display: 'flex',
              alignItems: 'center',
              padding: '10px 15px',
              marginBottom: '12px',
              borderRadius: '10px',
              backgroundColor: active ? 'white' : 'transparent',
              color: active ? '#FF600A' : 'white',
              fontWeight: 500,
              textDecoration: 'none',
              transition: 'all 0.2s ease-in-out',
              boxShadow: active ? '0 2px 8px rgba(0,0,0,0.05)' : 'none',
            }}
          >
            {link.icon}
            <span style={{ marginLeft: '12px' }}>{link.label}</span>
          </Link>
        );
      })}
    </div>
  );
};

export default Sidebar;
