// weeklyWorkPreference.model.js
const mongoose = require('mongoose');

const daySchema = new mongoose.Schema({
  day: {
    type: String,
    enum: ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'],
    required: true,
  },
  session_type: { type: String, enum: ['single', 'multiple'], default: 'single' },
  start_time: { type: String, required: true },
  end_time: { type: String, required: true },
});

const weeklyWorkPreferenceSchema = new mongoose.Schema({
  caregiver_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CareGiver',
    required: true,
    unique: true, // ✅ only one per caregiver
  },
  preferences: [daySchema], // ✅ embed all days in one doc
}, { timestamps: true });

module.exports = mongoose.model('WeeklyWorkPreference', weeklyWorkPreferenceSchema);
