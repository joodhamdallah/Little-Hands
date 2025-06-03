// services/feedbackService.js
const Feedback = require('../models/Feedback');
const Parent = require('../models/Parent');
const CareGiver = require('../models/CareGiver');

function calculateOverallRating(ratings) {
  const values = Object.values(ratings).filter(v => typeof v === 'number');
  if (values.length === 0) return null;

  const total = values.reduce((sum, v) => sum + v, 0);
  const average = total / values.length;
  return parseFloat(average.toFixed(1)); // e.g., 3.7
}

module.exports = {
  // ✅ 1. Submit new feedback
  async submitFeedback(req) {
    const {
      booking_id,
      to_user_id,
      to_role,
      from_role,
      ratings,
      comments,
      type,
    } = req.body;

  const overall_rating =
      type === 'completed' && ratings
        ? calculateOverallRating(ratings)
        : null;

        
    const feedback = new Feedback({
      booking_id,
      from_user_id: req.user._id,
      to_user_id,
      from_role,
      to_role,
      ratings,
      comments,
      overall_rating,
      type,
    });

    await feedback.save();
    return {
      status: 200,
      data: { message: 'Feedback submitted successfully', feedback },
    };

  },

  // ✅ 2. Get all feedback *received* by caregiver (admin/internal use)
  async getForCaregiver(caregiverId) {
    return await Feedback.find({ to_user_id: caregiverId, to_role: 'caregiver' })
      .sort({ created_at: -1 });
  },

  // ✅ 3. Get all feedback *received* by parent (admin/internal use)
  async getForParent(parentId) {
    return await Feedback.find({ to_user_id: parentId, to_role: 'parent' })
      .sort({ created_at: -1 });
  },

  // ✅ 4. Public feedback for caregiver (seen by parents before booking)
  async getPublicFeedbackForCaregiver(caregiverId) {
    return await Feedback.find({
      to_user_id: caregiverId,
      to_role: 'caregiver',
      type: 'completed',
    })
      .select('-from_user_id') // hide reviewer ID
      .sort({ created_at: -1 });
  },

  // ✅ 5. Public feedback for parent (seen by caregivers before accepting)
  async getPublicFeedbackForParent(parentId) {
    return await Feedback.find({
      to_user_id: parentId,
      to_role: 'parent',
      type: 'completed',
    })
      .select('-from_user_id')
      .sort({ created_at: -1 });
  },

  // ✅ 6. Check if current user already submitted feedback for a booking
  async checkFeedbackForBooking(req) {
    const existing = await Feedback.findOne({
      booking_id: req.params.bookingId,
      from_user_id: req.user._id,
    });

    return { exists: !!existing };
  },

  // ✅ 7. Get all feedbacks submitted by current user
  async getMyFeedbacks(userId) {
    return await Feedback.find({ from_user_id: userId })
      .sort({ created_at: -1 });
  },

  // ✅ 8. Update feedback (optional)
  async updateFeedback(id, req) {
    const updates = req.body;

    const feedback = await Feedback.findOneAndUpdate(
      { _id: id, from_user_id: req.user._id },
      updates,
      { new: true }
    );

    if (!feedback) {
      return {
        status: 404,
        data: { message: 'Feedback not found or not authorized' },
      };
    }

    return {
      status: 200,
      data: { message: 'Feedback updated', feedback },
    };
  },
};
