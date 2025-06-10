// routes/bookingRoutes.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

const generalBookingController = require('../controllers/bookings/generalBookingController');
const bookingBabysitterController = require('../controllers/bookings/bookingBabysitterController');

// 👪 Get all bookings for the logged-in parent
router.get('/bookings/parent', authMiddleware, generalBookingController.getParentBookings);

// 🧑‍⚕️ Get all bookings for the logged-in caregiver (all statuses)
router.get('/caregiver/bookings', authMiddleware, generalBookingController.getBookingsForCaregiver);

// 📅 Get confirmed bookings for a caregiver by their ID (used for calendars)
router.get('/bookings/caregiver/:id', generalBookingController.getBookingsByCaregiverId);


/////////////////Babysitter Service//////////////////////
// 👶 Create a babysitter booking request (by parent)
router.post('/bookings', authMiddleware, bookingBabysitterController.createBooking);

// ✅ Confirm a babysitter booking (by parent)
router.patch('/bookings/:id/confirm', authMiddleware, bookingBabysitterController.confirmBooking);

// ❌ Reject a babysitter booking (by caregiver)
router.patch('/bookings/:id/reject', authMiddleware, bookingBabysitterController.rejectBooking);

// 👍 Accept a babysitter booking (by caregiver)
router.patch('/bookings/:id/accept', authMiddleware, bookingBabysitterController.acceptBooking);

// 📆 Book a meeting with the babysitter (by parent)
router.patch('/bookings/:id/book-meeting', authMiddleware, bookingBabysitterController.bookMeeting);

// 🔁 Cancel a babysitter booking (by either party)
router.patch('/bookings/:id/cancel', authMiddleware, bookingBabysitterController.cancelBooking);

// 🏁 Mark a babysitting session as completed
router.patch('/bookings/:id/mark-completed', authMiddleware, bookingBabysitterController.markCompleted);

// 💰 Mark a babysitting session as paid (after payment success)
router.patch('/bookings/:id/payment-success', authMiddleware, bookingBabysitterController.markAsPaid);

// set price by caregiver
router.post('/setPrice/:bookingId', authMiddleware, bookingBabysitterController.setPrice);

// Set payment method (cash or online)
router.patch('/bookings/:id/payment-method', authMiddleware, bookingBabysitterController.setPaymentMethod);

router.post('/fallback-booking', authMiddleware, bookingBabysitterController.createFallbackBooking);


module.exports = router;
