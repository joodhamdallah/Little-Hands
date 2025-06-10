const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const fallbackController = require('../controllers/fallbackController');

router.post('/fallbacks/respond', auth, fallbackController.respondToFallback);
router.get('/fallbacks/candidates/:bookingId', auth, fallbackController.getFallbackCandidates);

module.exports = router;
