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
    console.log("🧠 Age:", result.data.age?.[0]?.value);
    console.log("🧠 Full Name:", result.data.fullName?.[0]?.value);
    console.log("🧠 Document Number:", result.data.documentNumber?.[0]?.value);

    if (result.error) {
      console.log("🔍 Full error from ID Analyzer:", result);
      return res.status(400).json({ error: result.error.message });
    }

    if (result.success) {
      const decision = result.decision;
      const faceMatch = result.data.face?.[0]?.confidence ?? null;

      // Check warnings for face mismatch
      const hasFaceMismatch = result.warning?.some(
        (w) => w.code === 'FACE_MISMATCH' && w.decision === 'reject'
      );

      console.log("🧠 Face Match Confidence:", faceMatch);
      if (hasFaceMismatch || decision === 'reject') {
        return res.status(200).json({
          success: true,
          decision: 'reject',
          fullName: result.data.fullName?.[0]?.value,
          idNumber: result.data.documentNumber?.[0]?.value,
          faceMatchConfidence: faceMatch,
          reason: 'face_mismatch',
        });
      }

      return res.json({
        success: true,
        decision,
        fullName: result.data.fullName?.[0]?.value,
        idNumber: result.data.documentNumber?.[0]?.value,
        age: result.data.age?.[0]?.value, // ✅ include age here
        faceMatchConfidence: faceMatch,
        warnings: result.warning || [], // ✅ make sure this exists
        imageUrls: result.outputImage || {},
      });
    }

    return res.status(400).json({ error: 'Face match failed or document invalid.' });

  } catch (err) {
    console.error("❌ ERROR:", err?.response?.data || err.message || err);
    res.status(500).json({ error: 'Verification failed. Please try again later.' });
  }
};

module.exports = { verifyID };
