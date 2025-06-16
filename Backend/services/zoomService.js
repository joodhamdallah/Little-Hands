// services/zoomService.js
const axios = require('axios');
require('dotenv').config();

async function getAccessToken() {
  const response = await axios.post('https://zoom.us/oauth/token', null, {
    params: {
      grant_type: 'account_credentials',
      account_id: process.env.ZOOM_ACCOUNT_ID,
    },
    auth: {
      username: process.env.ZOOM_CLIENT_ID,
      password: process.env.ZOOM_CLIENT_SECRET,
    },
  });

  return response.data.access_token;
}

async function createZoomMeeting(topic = 'Little Hands Session') {
  const token = await getAccessToken();

  const response = await axios.post(
    'https://api.zoom.us/v2/users/me/meetings',
    {
      topic,
      type: 1, // Instant meeting
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    }
  );

  return response.data; // contains join_url, start_url, etc.
}

module.exports = { createZoomMeeting };
