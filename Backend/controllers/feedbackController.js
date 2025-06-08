const feedbackService = require('../services/feedbackService');

// ✅ Create feedback
exports.submitFeedback = async (req, res) => {
  try {
    const result = await feedbackService.submitFeedback(req);
    res.status(result.status).json(result.data);
  } catch (err) {
    console.error('❌ Feedback error:', err);
    res.status(500).json({ error: 'Something went wrong' });
  }
};

// ✅ Get all feedback for a caregiver (given to them)
exports.getForCaregiver = async (req, res) => {
  try {
    const result = await feedbackService.getForCaregiver(req.user._id);
    res.json({ feedbacks: result });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch caregiver feedback' });
  }
};

// ✅ Get all feedback for a parent (given to them)
exports.getForParent = async (req, res) => {
  try {
    const result = await feedbackService.getForParent(req.user._id);
    res.json({ feedbacks: result });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch parent feedback' });
  }
};

// ✅ Public feedback (for booking page) – caregiver
exports.getPublicFeedbackForCaregiver = async (req, res) => {
  try {
    const result = await feedbackService.getPublicFeedbackForCaregiver(req.params.id);
    res.json({ feedbacks: result });
  } catch (err) {
    res.status(500).json({ error: 'Error fetching caregiver feedback' });
  }
};

// ✅ Public feedback (for request review) – parent
exports.getPublicFeedbackForParent = async (req, res) => {
  try {
    const feedbacks = await feedbackService.getPublicFeedbackForParent(req.params.id);

    const parent = feedbacks.length > 0 ? feedbacks[0].to_user_id : null;
    const parentName = parent ? `${parent.firstName} ${parent.lastName}` : 'ولي الأمر';

    res.json({
      feedbacks,
      parent_name: parentName
    });
  } catch (err) {
    res.status(500).json({ error: 'Error fetching parent feedback' });
  }
};


// ✅ Check if user already submitted feedback for this booking
exports.checkFeedbackForBooking = async (req, res) => {
  try {
    const result = await feedbackService.checkFeedbackForBooking(req);
    res.json(result);
  } catch (err) {
    res.status(500).json({ error: 'Error checking feedback' });
  }
};
exports.getMyFeedbacks = async (req, res) => {
  try {
    const result = await feedbackService.getMyFeedbacks(req.user._id);

    const formatted = result.map(fb => {
      const base = fb.toObject({ depopulate: false }); // ✅ preserve populated fields
      const caregiver = base.to_user_id || {};
      const booking = base.booking_id || {};

      // ✅ Convert Mongoose Map to plain JS object
      const ratings = base.ratings instanceof Map ? Object.fromEntries(base.ratings) : base.ratings ?? {};
      const comments = base.comments instanceof Map ? Object.fromEntries(base.comments) : base.comments ?? {};

      return {
        _id: base._id,
        caregiver_id: caregiver._id ?? null,
        caregiver_name: `${caregiver.first_name ?? ''} ${caregiver.last_name ?? ''}`,
        ratings,
        comments,
        overall_rating:base.overall_rating ?? null,
        type: base.type ?? '',
        created_at: base.created_at,
        session_start_date: booking.session_start_date ?? null,
      };
    });

    res.json({ feedbacks: formatted });
  } catch (err) {
    console.error("❌ Failed to fetch feedbacks:", err);
    res.status(500).json({ error: 'Failed to fetch your feedbacks' });
  }
};



// ✅ (Optional) Edit feedback
exports.updateFeedback = async (req, res) => {
  try {
    const result = await feedbackService.updateFeedback(req.params.id, req);
    res.status(result.status).json(result.data);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update feedback' });
  }
};

exports.getRatedBookings = async (req, res) => {
  try {
    const fromUserId = req.user._id;
    const bookingIds = await feedbackService.getRatedBookingIds(fromUserId);
    res.json({ booking_ids: bookingIds });
  } catch (err) {
    console.error('❌ Failed to get rated bookings:', err);
    res.status(500).json({ message: 'Server error' });
  }
};