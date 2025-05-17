const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const controller = require('../controllers/specificDatePreferenceController');
//get by caregiver using token
router.get('/specific-date-preferences', authMiddleware, controller.getAllSpecificDates);

//get specific dates by parent or public
router.get('/specific-date-preferences/:caregiverId', controller.getAllSpecificDatesByCaregiver);

// Disabling a specific date + Editing session info for a specific date
router.put('/specific-date-preferences', authMiddleware, controller.saveOrUpdateDate);
router.delete('/specific-date-preferences/:date', authMiddleware, controller.deleteSpecificDate);

module.exports = router;
