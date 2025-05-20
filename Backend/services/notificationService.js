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

 static async sendTypedNotification({
  user_id,
  user_type,
  title,
  message,
  type = 'general',
  fcm_token = null,
  data = {},
}) {
  await Notification.create({
    user_id,
    user_type,
    title,
    message,
    type,
    data,
    read: false,
  });

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
