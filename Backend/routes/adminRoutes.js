const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/adminController');

router.get('/summary', AdminController.getSummary);
router.get('/booking-trends', AdminController.getBookingTrends);
router.get('/users', AdminController.getAllUsers);
router.delete('/user/:id', AdminController.deleteUser);

module.exports = router;
