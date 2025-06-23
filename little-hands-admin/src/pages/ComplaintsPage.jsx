import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Complaints = () => {
  const [complaints, setComplaints] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:3000/api/complaints')
      .then(res => setComplaints(res.data.data))
      .catch(err => console.error('Error loading complaints', err));
  }, []);

  return (
    <div style={{ padding: '30px' }}>
      <h2 style={{ fontFamily: 'NotoSansArabic', marginBottom: '20px' }}>الشكاوى المقدمة</h2>
      <div style={{ overflowX: 'auto' }}>
        <table style={{
          width: '100%',
          borderCollapse: 'collapse',
          fontFamily: 'NotoSansArabic',
          boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
        }}>
          <thead>
            <tr style={{ backgroundColor: '#FF600A', color: 'white' }}>
              <th style={thStyle}>اسم مقدم الرعاية</th>
              <th style={thStyle}>نوع الجلسة</th>
              <th style={thStyle}>تاريخ الجلسة</th>
              <th style={thStyle}>الموضوع</th>
              <th style={thStyle}>التفاصيل</th>
              <th style={thStyle}>اسم الوالد</th> {/* ✅ NEW */}
            </tr>
          </thead>
          <tbody>
            {complaints.map((c, i) => (
              <tr key={i} style={{ textAlign: 'center', backgroundColor: i % 2 === 0 ? '#f9f9f9' : '#fff' }}>
                <td style={tdStyle}>{c.caregiver_name}</td>
                <td style={tdStyle}>{c.session_type}</td>
                <td style={tdStyle}>{new Date(c.session_date).toLocaleDateString()}</td>
                <td style={tdStyle}>{c.subject}</td>
                <td style={tdStyle}>{c.details}</td>
                <td style={tdStyle}>
                  {c.parent_id?.firstName} {c.parent_id?.lastName}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

const thStyle = {
  padding: '12px',
  fontSize: '14px',
  fontWeight: 'bold',
};

const tdStyle = {
  padding: '10px',
  fontSize: '13px',
};

export default Complaints;
