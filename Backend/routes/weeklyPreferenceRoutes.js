const express = require('express');
const router = express.Router();
const workPreferenceController = require('../controllers/weeklyPreferenceController.js');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/weekly-preferences', authMiddleware, workPreferenceController.saveWeeklyWorkPreferences);
router.get('/weekly-preferences',authMiddleware, workPreferenceController.getWeeklyWorkPreferences);

//get weekely prefrences by parent or public
router.get(
  '/weekly-preferences/:caregiverId',
  workPreferenceController.getWeeklyWorkPreferencesByCaregiver
);

module.exports = router;