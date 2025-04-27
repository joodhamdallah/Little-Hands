const express = require('express');
const router = express.Router();
const WorkScheduleController= require('../controllers/workscheduleController');
const authMiddleware = require('../middleware/authMiddleware'); 

//  Create a work schedule
router.post('/', authMiddleware, WorkScheduleController.createWorkSchedule);

//  Get all schedules for logged-in caregiver
router.get('/', authMiddleware, WorkScheduleController.getWorkSchedules);

//  Delete a schedule by ID
router.delete('/:id', authMiddleware, WorkScheduleController.deleteWorkSchedule);

module.exports = router;
