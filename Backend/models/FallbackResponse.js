const mongoose = require('mongoose');

const fallbackResponseSchema = new mongoose.Schema({
  booking_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Booking',
    required: true,
  },
  caregiver_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CareGiver',
    required: true,
  },
  responded_at: {
    type: Date,
    default: Date.now,
  },
  accepted: {
    type: Boolean,
    default: true, // for now, it's always "نعم أرغب"
  },
});

module.exports = mongoose.model('FallbackResponse', fallbackResponseSchema);
