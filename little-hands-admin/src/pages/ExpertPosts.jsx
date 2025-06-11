import React, { useEffect, useState } from 'react';
import axios from 'axios';

const ExpertPosts = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = () => {
    setLoading(true);
axios.get('http://localhost:3000/api/admin/expert-posts')
      .then(res => {
        setPosts(res.data);
        setLoading(false);
      })
      .catch(err => {
        console.error('❌ Failed to fetch posts:', err);
        setLoading(false);
      });
  };

  const handleDelete = (postId) => {
    if (!window.confirm("Are you sure you want to delete this post?")) return;

    axios.delete(`http://localhost:3000/api/expert-posts/${postId}`)
      .then(() => {
        setPosts(prev => prev.filter(p => p._id !== postId));
      })
      .catch(err => {
        console.error('❌ Failed to delete post:', err);
      });
  };

  return (
    <div>
      <h1 style={{ color: '#333', marginBottom: '20px' }}>🧠 Expert Posts</h1>
      {loading ? (
        <p>Loading expert posts...</p>
      ) : (
        <table style={tableStyle}>
          <thead style={{ backgroundColor: '#f4f4f4' }}>
            <tr>
              <th style={th}>Title</th>
              <th style={th}>Summary</th>
              <th style={th}>Expert</th>
              <th style={th}>Date</th>
              <th style={th}>Actions</th>
            </tr>
          </thead>
          <tbody>
            {posts.map(post => (
              <tr key={post._id}>
                <td style={td}>{post.title}</td>
                <td style={td}>{post.summary}</td>
                <td style={td}>{post.expertName}</td>
                <td style={td}>{new Date(post.createdAt).toLocaleDateString()}</td>
                <td style={td}>
                  <button
                    onClick={() => handleDelete(post._id)}
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

const deleteBtnStyle = {
  backgroundColor: '#ff4d4f',
  color: 'white',
  border: 'none',
  borderRadius: '6px',
  padding: '6px 10px',
  cursor: 'pointer'
};

export default ExpertPosts;
