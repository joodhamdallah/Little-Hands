// AdminBookingsPage.jsx
import React, { useEffect, useState } from 'react';
import axios from 'axios';

const statusColors = {
  pending: '#FFD700',
  accepted: '#87CEFA',
  rejected: '#FA8072',
  meeting_booked: '#FFA500',
  confirmed: '#90EE90',
  cancelled: '#D3D3D3',
  completed: '#B0E0E6'
};

const AdminBookingsPage = () => {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all');
  const [serviceFilter, setServiceFilter] = useState('all');

  useEffect(() => {
    fetchBookings();
  }, []);

  const fetchBookings = () => {
    axios.get('http://localhost:3000/api/admin/bookings')
      .then(res => {
        setBookings(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('❌ Failed to fetch bookings:', err);
        setLoading(false);
      });
  };

  const filtered = bookings.filter(b => {
    const statusMatch = statusFilter === 'all' || b.status === statusFilter;
    const serviceMatch = serviceFilter === 'all' || b.service_type === serviceFilter;
    return statusMatch && serviceMatch;
  });

  return (
    <div>
      <h1 style={{ marginBottom: '20px' }}>📅 Bookings</h1>

      <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
        <div>
          <label>Status:</label><br />
          <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="all">All</option>
            <option value="pending">Pending</option>
            <option value="accepted">Accepted</option>
            <option value="rejected">Rejected</option>
            <option value="meeting_booked">Meeting Booked</option>
            <option value="confirmed">Confirmed</option>
            <option value="cancelled">Cancelled</option>
            <option value="completed">Completed</option>
          </select>
        </div>
        <div>
          <label>Service Type:</label><br />
          <select value={serviceFilter} onChange={e => setServiceFilter(e.target.value)}>
            <option value="all">All</option>
            <option value="babysitter">Babysitter</option>
            <option value="consultant">Consultant</option>
            <option value="special_needs">Special Needs</option>
            <option value="tutor">Tutor</option>
          </select>
        </div>
      </div>

      {loading ? <p>Loading...</p> : (
        <table style={{ width: '100%', background: 'white', borderRadius: 8, boxShadow: '0 2px 6px rgba(0,0,0,0.05)' }}>
          <thead style={{ backgroundColor: '#f4f4f4' }}>
            <tr>
              <th>Parent</th>
              <th>Caregiver</th>
              <th>Service</th>
              <th>Date</th>
              <th>Status</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((b, i) => (
              <tr key={i}>
                <td>{b.parent?.name || 'Unknown'}</td>
                <td>{b.caregiver?.name || 'Unknown'}</td>
                <td>{b.service_type}</td>
                <td>{new Date(b.session_start_date).toLocaleDateString()}</td>
                <td style={{ color: statusColors[b.status], fontWeight: 'bold' }}>{b.status}</td>
                <td>{b.price_details?.total ? `$${b.price_details.total}` : '-'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default AdminBookingsPage;