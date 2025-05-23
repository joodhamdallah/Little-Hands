const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const  authMiddleware  = require('../middleware/authMiddleware');

// 🧑‍👧‍👦 إنشاء حجز
router.post('/bookings', authMiddleware, bookingController.createBooking);
// routes/bookingRoutes.js
router.get('/caregiver/bookings', authMiddleware, bookingController.getBookingsForCaregiver);

// get caregiver bookings by caregiver id
router.get('/bookings/caregiver/:id', bookingController.getBookingsByCaregiverId);

router.patch('/bookings/:id/confirm', authMiddleware, bookingController.confirmBooking);

//router.patch('/bookings/:id/reject', authMiddleware, bookingController.rejectBooking); // ✅ NEW LINE

router.get('/bookings/parent', authMiddleware, bookingController.getParentBookings);

module.exports = router;
