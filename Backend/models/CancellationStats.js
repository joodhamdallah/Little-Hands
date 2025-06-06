const mongoose = require('mongoose');

const cancellationStatsSchema = new mongoose.Schema({
  user_id: { type: mongoose.Schema.Types.ObjectId, required: true, index: true },
  role: { type: String, enum: ['parent', 'caregiver'], required: true },
  stats: {
    pending: { type: Number, default: 0 },
    accepted: { type: Number, default: 0 },
    meeting_booked: { type: Number, default: 0 },
    confirmed: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
  }
}, { timestamps: true });

module.exports = mongoose.model('CancellationStats', cancellationStatsSchema);
