const express = require('express');
const router = express.Router();
const feedbackController = require('../controllers/feedbackController');
const auth = require("../middleware/authMiddleware");

// ✅ Create feedback
router.post('/', auth, feedbackController.submitFeedback);

// 🔁 Optional: Update feedback
// router.put('/:id', auth, feedbackController.updateFeedback);

// ✅ Get feedback given to caregiver
router.get('/caregiver/:id', auth, feedbackController.getForCaregiver);

// ✅ Get feedback given to parent
router.get('/parent/:id', auth, feedbackController.getForParent);

// 📥 Public (visible) caregiver feedback (for parents to see)
router.get('/about/caregiver/:id', feedbackController.getPublicFeedbackForCaregiver);

// 📥 Public (visible) parent feedback (for caregivers to see)
router.get('/about/parent/:id', feedbackController.getPublicFeedbackForParent);

// ✅ Check if booking already has feedback
router.get('/booking/:bookingId', auth, feedbackController.checkFeedbackForBooking);

// 👤 Optional: View my own submitted feedbacks
router.get('/mine', auth, feedbackController.getMyFeedbacks);


router.get('/my-rated-bookings', auth, feedbackController.getRatedBookings);

module.exports = router;
