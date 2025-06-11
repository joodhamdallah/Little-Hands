import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Users = () => {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [roleFilter, setRoleFilter] = useState('all');
  const [cityFilter, setCityFilter] = useState('all');

  const roleOptions = [
    { label: 'All', value: 'all' },
    { label: 'Parents', value: 'parent' },
    { label: 'Babysitters', value: 'babysitter' },
    { label: 'Experts', value: 'expert' },
    { label: 'Special Needs', value: 'special_needs' },
  ];

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = () => {
    setLoading(true);
    axios.get('http://localhost:3000/api/admin/users')
      .then(res => {
        setUsers(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('❌ Failed to fetch users:', err);
        setLoading(false);
      });
  };

  const handleDelete = (userId) => {
    if (!window.confirm("Are you sure you want to delete this user?")) return;

    axios.delete(`http://localhost:3000/api/admin/user/${userId}`)
      .then(() => {
        setUsers(prev => prev.filter(u => u.id !== userId));
      })
      .catch(err => {
        console.error('❌ Failed to delete user:', err);
      });
  };

  const allCities = [...new Set(users.map(u => u.city).filter(Boolean))];

  const filteredUsers = users.filter(u => {
    const roleMatch = roleFilter === 'all' || u.role === roleFilter;
    const cityMatch = cityFilter === 'all' || u.city === cityFilter;
    return roleMatch && cityMatch;
  });

  return (
    <div>
      <h1 style={{ color: '#333', marginBottom: '20px' }}>👥 Users</h1>

      <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
        <div>
          <label style={labelStyle}>Filter by Role:</label><br />
          <select value={roleFilter} onChange={e => setRoleFilter(e.target.value)} style={selectStyle}>
            {roleOptions.map((option, idx) => (
              <option key={idx} value={option.value}>{option.label}</option>
            ))}
          </select>
        </div>
        <div>
          <label style={labelStyle}>Filter by City:</label><br />
          <select value={cityFilter} onChange={e => setCityFilter(e.target.value)} style={selectStyle}>
            <option value="all">All</option>
            {allCities.map((city, index) => (
              <option key={index} value={city}>{city}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <p>Loading users...</p>
      ) : (
        <table style={tableStyle}>
          <thead style={{ backgroundColor: '#f4f4f4' }}>
            <tr>
              <th style={th}>Name</th>
              <th style={th}>Email</th>
              <th style={th}>Role</th>
              <th style={th}>City</th>
              <th style={th}>Joined</th>
              <th style={th}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filteredUsers.map((u, index) => (
              <tr key={index}>
                <td style={td}>{u.name}</td>
                <td style={td}>{u.email}</td>
                <td style={td}>{u.role}</td>
                <td style={td}>{u.city || '-'}</td>
                <td style={td}>{new Date(u.joined).toLocaleDateString()}</td>
                <td style={td}>
                  <button
                    onClick={() => handleDelete(u.id)}
                    style={deleteBtnStyle}
                  >
                    🗑 Delete
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

// Styles
const tableStyle = {
  width: '100%',
  borderCollapse: 'collapse',
  backgroundColor: 'white',
  borderRadius: '12px',
  overflow: 'hidden',
  boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
};

const th = {
  textAlign: 'left',
  padding: '12px',
  fontWeight: 'bold',
  color: '#333',
  fontSize: '14px',
};

const td = {
  padding: '12px',
  borderTop: '1px solid #eee',
  fontSize: '14px',
};

const labelStyle = {
  fontWeight: 'bold',
  color: '#555',
  fontSize: '14px',
};

const selectStyle = {
  padding: '8px',
  fontSize: '14px',
  borderRadius: '6px',
  border: '1px solid #ccc',
  marginTop: '4px'
};

const deleteBtnStyle = {
  backgroundColor: '#ff4d4f',
  color: 'white',
  border: 'none',
  borderRadius: '6px',
  padding: '6px 10px',
  cursor: 'pointer'
};

export default Users;
