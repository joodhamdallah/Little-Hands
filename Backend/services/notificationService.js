const Notification = require('../models/Notification');

class NotificationService {
  static async createNotification({ user_id, user_type ,title, message, type = 'general' }) {
    const notification = await Notification.create({
      user_id,
      user_type,
      title,
      message,
      type,
      read: false,
    });
    return notification;
  }

  static async markAsRead(notificationId) {
    return Notification.findByIdAndUpdate(notificationId, { read: true }, { new: true });
  }

  static async getUserNotifications(userId) {
    return Notification.find({ user_id: userId }).sort({ createdAt: -1 });
  }
}

module.exports = NotificationService;
