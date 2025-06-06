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
    const result = await feedbackService.getPublicFeedbackForParent(req.params.id);
    res.json({ feedbacks: result });
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

// ✅ NEW: Get all feedbacks submitted by logged-in user
exports.getMyFeedbacks = async (req, res) => {
  try {
    const result = await feedbackService.getMyFeedbacks(req.user._id);
    res.json({ feedbacks: result });
  } catch (err) {
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
