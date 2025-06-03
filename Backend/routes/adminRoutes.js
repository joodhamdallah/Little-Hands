const express = require('express');
const router = express.Router();
const AdminController = require('../controllers/adminController');

router.get('/summary', AdminController.getSummary);
router.get('/booking-trends', AdminController.getBookingTrends);
router.get('/users', AdminController.getAllUsers);
router.delete('/user/:id', AdminController.deleteUser);
router.get('/bookings', AdminController.getAllBookings);
router.get('/expert-posts', AdminController.getAllExpertPosts);
router.delete('/expert-posts/:id', AdminController.deleteExpertPost);

module.exports = router;
