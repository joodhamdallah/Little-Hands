const express = require('express');
const router = express.Router();
const NotificationController = require('../controllers/notificationController');
const authMiddleware= require('../middleware/authMiddleware');

router.get('/notifications', authMiddleware, NotificationController.getMyNotifications);
router.put('/notifications/:id/read', NotificationController.markAsRead);

//router.put('/mark-all-read', authMiddleware, NotificationController.markAllAsRead);

module.exports = router;
