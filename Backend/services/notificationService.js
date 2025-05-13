const Notification = require('../models/Notification');
const sendFCM = require('../firebase/sendNotification');

class NotificationService {
  static async createNotification({ user_id, user_type, title, message, type = 'general', data = {} }) {
    return Notification.create({
      user_id,
      user_type,
      title,
      message,
      type,
      data,
      read: false,
    });
  }

  static async sendBookingNotification({ user_id, user_type, title, message, type = 'booking_request', fcm_token = null, data = {} }) {
    // 👇 Save to DB
    await Notification.create({
      user_id,
      user_type,
      title,
      message,
      type,
      data,
      read: false,
    });

    // 👇 Send FCM if token exists
    if (fcm_token) {
      await sendFCM(fcm_token, title, message, data);
    }
  }

  static async markAsRead(notificationId) {
    return Notification.findByIdAndUpdate(notificationId, { read: true }, { new: true });
  }

  static async getUserNotifications(userId) {
    return Notification.find({ user_id: userId }).sort({ createdAt: -1 });
  }
}

module.exports = NotificationService;
