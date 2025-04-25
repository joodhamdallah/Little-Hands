const express = require('express');
const router = express.Router();
const { handleCheckoutSession } = require('../controllers/stripeController');
const authMiddleware = require('../middleware/authMiddleware'); 

// POST /api/subscribe
router.post('/subscribe', authMiddleware, handleCheckoutSession);

module.exports = router;
