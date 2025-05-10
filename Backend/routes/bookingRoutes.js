const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const  authMiddleware  = require('../middleware/authMiddleware');

// 🧑‍👧‍👦 إنشاء حجز
router.post('/bookings', authMiddleware, bookingController.createBooking);
// routes/bookingRoutes.js
router.get('/caregiver/bookings', authMiddleware, bookingController.getBookingsForCaregiver);


module.exports = router;
