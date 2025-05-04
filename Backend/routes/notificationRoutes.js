const express = require('express');
const router = express.Router();
const NotificationController = require('../controllers/notificationController');
const authMiddleware= require('../middleware/authMiddleware');

router.get('/', authMiddleware, NotificationController.getMyNotifications);
router.put('/:id/read', NotificationController.markAsRead);

module.exports = router;
