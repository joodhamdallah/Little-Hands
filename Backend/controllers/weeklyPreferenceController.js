const WeeklyWorkPreference = require('../models/WeeklyWorkPreference.js');

exports.saveWeeklyWorkPreferences = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const { preferences } = req.body;

    if (!Array.isArray(preferences)) {
      return res.status(400).json({ status: false, message: 'Invalid preferences data.' });
    }

    const updated = await WeeklyWorkPreference.findOneAndUpdate(
      { caregiver_id: caregiverId },
      { preferences },
      { new: true, upsert: true }
    );

    res.status(201).json({ status: true, message: 'Preferences saved successfully.', data: updated });
  } catch (err) {
    console.error('❌ Error saving preferences:', err.message);
    res.status(500).json({ status: false, message: 'Internal server error.' });
  }
};

exports.getWeeklyWorkPreferences = async (req, res) => {
  try {
    const caregiverId = req.user._id;
const preferences = await WeeklyWorkPreference.findOne({ caregiver_id: caregiverId });
    res.status(200).json({ status: true, data: preferences });
  } catch (err) {
    console.error('❌ Error fetching preferences:', err.message);
    res.status(500).json({ status: false, message: 'Internal server error.' });
  }
};

// ✅ Used by parent (via caregiverId in URL)
exports.getWeeklyWorkPreferencesByCaregiver = async (req, res) => {
  try {
    const caregiverId = req.params.caregiverId;
     const preferences = await WeeklyWorkPreference.findOne({ caregiver_id: caregiverId });

    if (!preferences) {
      return res.status(404).json({ status: false, message: 'No preferences found' });
    }

    res.status(200).json({ status: true, data: preferences });
  } catch (err) {
    console.error('❌ Error fetching caregiver preferences:', err.message);
    res.status(500).json({ status: false, message: 'Internal server error' });
  }
};
