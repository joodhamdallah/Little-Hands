const axios = require('axios');

const verifyIDWithAnalyzer = async (idImage, selfieImage) => {
  console.log("🔄 Sending request to ID Analyzer");

  const response = await axios.post(
    'https://api.idanalyzer.com/v2/coreapi',
    {
      apiKey: process.env.ID_ANALYZER_API_KEY,
      documentPrimary: idImage,
      biometricPhoto: selfieImage,
      verifyFace: true,
      verifyDocument: true,
      outputImage: false,
      country: 'PS'
    },
    {
      headers: {
        'Content-Type': 'application/json'
      },
      validateStatus: () => true
    }
  );

  console.log("📥 Response from ID Analyzer:", response.status);
  console.log("🧠 Result from ID Analyzer:", response.data);
  return response.data;
};

module.exports = { verifyIDWithAnalyzer };
