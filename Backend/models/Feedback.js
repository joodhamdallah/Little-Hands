const mongoose = require('mongoose');
const { Schema } = mongoose;

/**
 * Feedback Model Schema
 * ---------------------
 * Stores feedback exchanged between parents and caregivers
 * after a session is completed or cancelled.
 */
const FeedbackSchema = new Schema({
  booking_id: {
    type: Schema.Types.ObjectId,
    ref: 'Booking',
    required: true,
  },

  from_user_id: {
    type: Schema.Types.ObjectId,
    required: true,
  },

  to_user_id: {
    type: Schema.Types.ObjectId,
    required: true,
  },

  from_role: {
    type: String,
    enum: ['parent', 'caregiver'],
    required: true,
  },

  to_role: {
    type: String,
    enum: ['parent', 'caregiver'],
    required: true,
  },

  // Detailed ratings (keyed by question)
  ratings: {
    type: Map,
    of: Number, // Use Boolean if for yes/no questions
    default: {},
  },

  // Optional textual comments (keyed by question)
  comments: {
    type: Map,
    of: String,
    default: {},
  },

  // Overall 1–5 star rating
  overall_rating: {
    type: Number,
    min: 1,
    max: 5,
    default: null,
  },

  // Feedback type: session completed or cancelled
  type: {
    type: String,
    enum: ['completed', 'cancelled'],
    required: true,
  },

  created_at: {
    type: Date,
    default: Date.now,
  },
});

// Prevent duplicate feedback per user/booking
FeedbackSchema.index({ booking_id: 1, from_user_id: 1 }, { unique: true });

module.exports = mongoose.model('Feedback', FeedbackSchema);
