const NotificationService = require('../services/notificationService');

exports.getMyNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const notifications = await NotificationService.getUserNotifications(userId);
    res.json({ status: true, data: notifications });
  } catch (error) {
    res.status(500).json({ status: false, message: "خطأ في جلب الإشعارات" });
  }
};

exports.markAsRead = async (req, res) => {
  try {
    const notification = await NotificationService.markAsRead(req.params.id);
    res.json({ status: true, data: notification });
  } catch (error) {
    res.status(500).json({ status: false, message: "فشل في تحديث حالة الإشعار" });
  }
};
