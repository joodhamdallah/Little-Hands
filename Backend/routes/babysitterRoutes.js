
const express = require('express');
const router = express.Router();
const babysitterController = require('../controllers/babysitterController');

router.post('/details', babysitterController.saveBabySitterDetails);

module.exports = router;
