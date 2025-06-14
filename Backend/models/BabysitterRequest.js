const mongoose = require('mongoose');

const BabysitterRequestSchema = new mongoose.Schema({
  parent_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  city: String,
  location: {
    lat: Number,
    lng: Number,
  },
  location_note: String,

  session_type: { type: String, enum: ['regular', 'once', 'nanny'], required: true },

  children_ages: [String],
  has_medical_condition: Boolean,
  medical_condition_details: String,
  takes_medicine: Boolean,
  medicine_details: String,
  additional_notes: String,

  rate_min: Number,
  rate_max: Number,
  is_negotiable: Boolean,

  additional_requirements: [String], // both extra & responsibilities

  status: {
    type: String,
    enum: ['pending', 'matched', 'cancelled', 'confirmed'],
    default: 'pending',
  },
  created_at: { type: Date, default: Date.now },
});

module.exports = mongoose.model('BabysitterRequest', BabysitterRequestSchema);
