const SpecificDatePreference = require('../models/SpecificDatePreference');

// 🔸 Create or update a specific date
exports.saveOrUpdateDate = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const { date, is_disabled, session_type, start_time, end_time } = req.body;

    const updated = await SpecificDatePreference.findOneAndUpdate(
      { caregiver_id: caregiverId, date },
      { is_disabled, session_type, start_time, end_time },
      { new: true, upsert: true }
    );

    res.status(200).json({ status: true, data: updated });
  } catch (error) {
    console.error('❌ Error saving specific date:', error.message);
    res.status(500).json({ status: false, message: 'Internal server error' });
  }
};

// ✅ Used by caregiver (via token)
exports.getAllSpecificDates = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const prefs = await SpecificDatePreference.find({ caregiver_id: caregiverId });
    res.status(200).json({ status: true, data: prefs });
  } catch (error) {
    console.error('❌ Error fetching specific dates:', error.message);
    res.status(500).json({ status: false, message: 'Internal server error' });
  }
};

// ✅ Used by parent/admin (via caregiverId in URL)
exports.getAllSpecificDatesByCaregiver = async (req, res) => {
  try {
    const caregiverId = req.params.caregiverId;
    const prefs = await SpecificDatePreference.find({ caregiver_id: caregiverId });
    res.status(200).json({ status: true, data: prefs });
  } catch (error) {
    console.error('❌ Error fetching caregiver specific dates:', error.message);
    res.status(500).json({ status: false, message: 'Internal server error' });
  }
};


// ❌ Delete a specific date preference (optional)
exports.deleteSpecificDate = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const { date } = req.params;

    await SpecificDatePreference.findOneAndDelete({ caregiver_id: caregiverId, date });
    res.status(200).json({ status: true, message: 'Date preference removed' });
  } catch (error) {
    console.error('❌ Error removing specific date:', error.message);
    res.status(500).json({ status: false, message: 'Internal server error' });
  }
};
