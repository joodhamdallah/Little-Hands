const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');
const fallbackController = require('../controllers/fallbackController');

router.post('/fallbacks/respond', auth, fallbackController.respondToFallback);

router.get('/fallbacks/candidates/:bookingId', auth, fallbackController.getFallbackCandidates);

// List unseen fallback offers for caregiver (to show in app even if received offline)
router.get('/fallbacks/unseen', auth, fallbackController.getUnseenOffers);

// Mark a fallback offer as seen
router.patch('/fallbacks/:id/seen', auth, fallbackController.markSeen);

// Future: cleanup expired fallback offers (can be a cron or on trigger)
// router.delete('/fallbacks/cleanup', fallbackController.cleanupExpiredOffers); // optional
module.exports = router;
