import React, { useEffect, useState } from 'react';
import axios from 'axios';
import {
  LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer
} from 'recharts';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [trendData, setTrendData] = useState([]);
  
  const news = [
    { title: "New caregiver features launched", date: "2025-06-01" },
    { title: "Expert post review policy updated", date: "2025-05-29" },
    { title: "Parents now can leave feedback", date: "2025-05-26" },
  ];

  useEffect(() => {
    // Fetch stats
    axios.get('http://localhost:3000/api/admin/summary')
      .then(res => setStats(res.data))
      .catch(err => console.error('❌ Failed to fetch stats:', err));

    // Fetch trends
    axios.get('http://localhost:3000/api/admin/booking-trends')
 .then(res => {
    console.log("📉 Trend Data:", res.data);
    setTrendData(res.data);
  })
  .catch(err => console.error('❌ Failed to fetch trends:', err));
  }, []);

  const statCards = [
    {
      title: 'Total Parents',
      key: 'parents',
      icon: '👨‍👩‍👧‍👦',
      color: '#FFD700',
    },
    {
      title: 'Total Caregivers',
      key: 'caregivers',
      icon: '🧑‍⚕️',
      color: '#7EC8E3',
    },
    {
      title: 'Total Bookings',
      key: 'bookings',
      icon: '📅',
      color: '#FF9AA2',
    },
    {
      title: 'Expert Posts',
      key: 'posts',
      icon: '🧠',
      color: '#B19CD9',
    },
  ];

  return (
    <div>
      <h1 style={{ color: '#333', marginBottom: '20px' }}>📊 Dashboard Overview</h1>

      {!stats ? (
        <p>Loading stats...</p>
      ) : (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: '20px',
        }}>
          {statCards.map((item, idx) => (
            <div key={idx}
              style={{
                backgroundColor: 'white',
                borderRadius: '14px',
                padding: '20px',
                boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
                display: 'flex',
                alignItems: 'center',
                gap: '16px',
              }}>
              <div style={{
                fontSize: '28px',
                backgroundColor: item.color,
                borderRadius: '12px',
                padding: '12px',
              }}>
                {item.icon}
              </div>
              <div>
                <div style={{ fontSize: '14px', color: '#888' }}>{item.title}</div>
                <div style={{ fontSize: '24px', fontWeight: 'bold' }}>
                  {stats[item.key]}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* 📈 Trends Chart */}
     <div style={{ marginTop: '40px' }}>
  <h2 style={{ marginBottom: '12px' }}>📈 Booking Trends (Last 7 Days)</h2>
  {trendData.length === 0 ? (
    <p>Loading chart...</p>
  ) : (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={trendData}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="day" />
        <YAxis />
        <Tooltip />
        <Line type="monotone" dataKey="bookings" stroke="#FF600A" strokeWidth={2} />
      </LineChart>
    </ResponsiveContainer>
  )}
</div>


      {/* 📰 Static News */}
      <div style={{ marginTop: '40px' }}>
        <h2 style={{ marginBottom: '12px' }}>📰 Latest Platform Updates</h2>
        <ul style={{ listStyle: 'none', padding: 0 }}>
          {news.map((item, index) => (
            <li key={index} style={{
              backgroundColor: '#fff',
              padding: '16px',
              marginBottom: '10px',
              borderRadius: '12px',
              boxShadow: '0 2px 6px rgba(0,0,0,0.05)'
            }}>
              <strong>{item.title}</strong>
              <div style={{ color: '#999', fontSize: '13px' }}>{item.date}</div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
};

export default Dashboard;
