const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    refPath: 'user_type', // 👈 dynamic reference
  },
  user_type: {
    type: String,
    required: true,
    enum: ['Parent', 'CareGiver', 'Admin'], // ✅ for future
  },
  title: { type: String, required: true },
  message: { type: String, required: true },
type: {
  type: String,
  enum: [
    'booking_request',          // parent → caregiver
    'booking_accepted',         // caregiver → parent
    'booking_rejected',
    'booking_cancelled_by_parent',
    'booking_cancelled_by_caregiver',
    'session_reminder',
    'system',
    'alert',
    'welcome',
    'general'
  ],
  default: 'alert',
},
  data: { type: mongoose.Schema.Types.Mixed }, // optional metadata
  read: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('Notification', notificationSchema);
