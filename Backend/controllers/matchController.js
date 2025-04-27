const MatchService = require('../services/matchService');

exports.matchBabysitters = async (req, res) => {
  try {
    const { city, childrenAges, rateMin, rateMax, additionalRequirements } = req.body;

    // // ✅ أطبع الداتا اللي واصلة من الفرونت
    // console.log("🚀 Incoming Matching Request:", {
    //   city,
    //   childrenAges,
    //   rateMin,
    //   rateMax,
    //   additionalRequirements
    // });

    const babysitters = await MatchService.matchBabysitters({
      city,
      childrenAges,
      rateMin,
      rateMax,
      additionalRequirements
    });

    // // ✅ أطبع النتيجة اللي طلعت بعد الماتشنج
    // console.log("🎯 Matching Result:", babysitters);

    res.status(200).json({ success: true, data: babysitters });
  } catch (error) {
    console.error('❌ Matching Babysitters Error:', error.message, '\n', error.stack);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
};

// 🆕 جديد: عرض ملف جليسة الأطفال بناءً على ID
exports.getBabysitterProfileById = async (req, res) => {
  try {
    const { id } = req.params;

    const profile = await MatchService.getBabysitterProfileById(id);

    if (!profile) {
      return res.status(404).json({ success: false, message: "Babysitter not found" });
    }

    res.status(200).json({ success: true, data: profile });
  } catch (error) {
    console.error('❌ Error fetching babysitter profile:', error.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};