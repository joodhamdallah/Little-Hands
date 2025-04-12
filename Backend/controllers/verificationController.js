const { verifyIDWithAnalyzer } = require('../services/idVerification');

const verifyID = async (req, res) => {
  const { idImage, selfieImage } = req.body;

  console.log("📩 Received ID and Selfie");

  if (!idImage || !selfieImage) {
    console.log("❌ Missing images");
    return res.status(400).json({ error: 'Both ID and selfie images are required.' });
  }

  try {
    const result = await verifyIDWithAnalyzer(idImage, selfieImage);
    console.log("🧠 Result from ID Analyzer:", result);

    if (result.error) return res.status(400).json({ error: result.error.message });

    if (result.result === 1 && result.face?.match === 1) {
      return res.json({
        success: true,
        name: result.document.name,
        idNumber: result.document.number,
      });
    } else {
      return res.status(400).json({ error: 'Face match failed or document invalid.' });
    }

  } catch (err) {
    console.error("❌ ERROR:", err?.response?.data || err.message || err);
    res.status(500).json({ error: 'Verification failed. Please try again later.' });
  }
};

module.exports = { verifyID };
