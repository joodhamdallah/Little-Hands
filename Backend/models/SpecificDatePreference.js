const mongoose = require('mongoose');

const specificDatePreferenceSchema = new mongoose.Schema({
  caregiver_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CareGiver',
    required: true,
  },
  date: {
    type: Date,
    required: true,
  },
  is_disabled: {
    type: Boolean,
    default: false,
  },
  session_type: {
    type: String,
    enum: ['single', 'multiple'],
  },
  start_time: { type: String }, // "HH:mm"
  end_time: { type: String },
}, {
  timestamps: true,
});

module.exports = mongoose.model('SpecificDatePreference', specificDatePreferenceSchema);
