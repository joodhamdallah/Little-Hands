// models/FallbackOffer.js
const mongoose = require('mongoose');

const fallbackOfferSchema = new mongoose.Schema({
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
  sent_at: {
    type: Date,
    default: Date.now,
  },
  seen: {
    type: Boolean,
    default: false,
  },
});

module.exports = mongoose.model('FallbackOffer', fallbackOfferSchema);
