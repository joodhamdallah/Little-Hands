const SpecialNeedsService = require("../services/specialNeedsService");

exports.saveSpecialNeedsProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const profile = await SpecialNeedsService.saveProfile(userId, req.body);
    res.status(201).json({ status: true, message: "Profile saved", data: profile });
  } catch (error) {
    res.status(400).json({ status: false, message: error.message });
  }
};

exports.getSpecialNeedsProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const profile = await SpecialNeedsService.getProfile(userId);
    if (!profile) return res.status(404).json({ status: false, message: "Profile not found" });
    res.status(200).json({ status: true, data: profile });
  } catch (error) {
    res.status(500).json({ status: false, message: "Server error" });
  }
};
