const ExpertService = require("../services/expertService");

exports.saveExpertProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const expert = await ExpertService.saveProfile(userId, req.body);
    res.status(201).json({ status: true, message: "Profile saved", data: expert });
  } catch (error) {
    res.status(400).json({ status: false, message: error.message });
  }
};

exports.getExpertProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const expert = await ExpertService.getProfile(userId);
    if (!expert) return res.status(404).json({ status: false, message: "Profile not found" });
    res.status(200).json({ status: true, data: expert });
  } catch (error) {
    res.status(500).json({ status: false, message: "Server error" });
  }
};
