// utils/sendNotification.js
const admin = require("./firebase");

const sendNotification = async (fcmToken, title, body, data = {}) => {
  const message = {
    token: fcmToken,
    notification: {
      title,
      body,
    },
    android: {
      priority: "high",
      notification: {
        sound: "default",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
        channelId: "high_importance_channel", // ✅ MUST match Flutter setup
      },
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
    },
    data: {
      ...data,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("✅ Notification sent:", response);
  } catch (error) {
    console.error("❌ Error sending notification:", error);
  }
};

module.exports = sendNotification;
