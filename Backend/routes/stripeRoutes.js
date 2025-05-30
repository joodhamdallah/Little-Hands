const express = require('express');
const router = express.Router();
const { handleCheckoutSession } = require('../controllers/stripeController');
const { handleBookingCheckoutSession } = require('../controllers/stripeController');
const authMiddleware = require('../middleware/authMiddleware'); 

// POST /api/subscribe
router.post('/subscribe', authMiddleware, handleCheckoutSession);

// POST /api/stripe/booking-checkout
router.post('/booking-checkout', authMiddleware, handleBookingCheckoutSession);

module.exports = router;
