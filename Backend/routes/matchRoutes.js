const express = require('express');
const router = express.Router();
const matchController = require('../controllers/matchController');
const authMiddleware = require('../middleware/authMiddleware'); // Protect parent routes

// ➔ Parent will search for babysitters
router.post('/match/babysitters', authMiddleware, matchController.matchBabysitters);

router.get('/babysitter/:id', matchController.getBabysitterProfileById);

module.exports = router;
