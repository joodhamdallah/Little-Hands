const axios = require('axios');

const verifyIDWithAnalyzer = async (idImage, selfieImage) => {
  console.log("🔄 Sending request to ID Analyzer /scan API");

  const response = await axios.post(
    'https://api2.idanalyzer.com/scan',  // ✅ OR use api2-eu.idanalyzer.com if you're using EU region
    {
      profile: process.env.KYC_PROFILE_ID,  // ✅ This is your saved KYC profile
      document: idImage,                    // ✅ ID image (base64)
      face: selfieImage                     // ✅ Selfie image (base64)
    },
    {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': process.env.ID_ANALYZER_API_KEY
      },
      validateStatus: () => true
    }
  );

  console.log("📥 Response from ID Analyzer:", response.status);
  console.log("🧠 Result from ID Analyzer:", response.data);
  return response.data;
};

module.exports = { verifyIDWithAnalyzer };
