const express = require('express');
const router = express.Router();
const babysitterController = require('../controllers/babysitterController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/details', authMiddleware, babysitterController.saveBabySitterDetails);

module.exports = router;
