// routes/complaintRoutes.js

const express = require('express');
const router = express.Router();
const complaintController = require('../controllers/complaintController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/complaints', authMiddleware, complaintController.submitComplaint);

// 🆕 Get all complaints (for admin)
router.get('/complaints', complaintController.getAllComplaints);
module.exports = router;
