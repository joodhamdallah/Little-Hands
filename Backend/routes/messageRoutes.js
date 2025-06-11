// routes/messages.js
const express = require("express");
const router = express.Router();
const sendNotification = require("../firebase/sendNotification");
const admin = require("../firebase/firebase");

router.post("/send-message", async (req, res) => {
  const { chatId, senderId, receiverId, fcmToken, text } = req.body;

  try {
    // Save message in Firestore
    const messageRef = admin.firestore()
      .collection("chats")
      .doc(chatId)
      .collection("messages");

    await messageRef.add({
      text,
      senderId,
      receiverId,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Send FCM notification
    await sendNotification(fcmToken, "رسالة جديدة", text, {
      chatId,
      senderId,
    });

    res.json({ success: true });
  } catch (err) {
    console.error("❌ Failed to send message:", err);
    res.status(500).json({ error: "Failed to send message" });
  }
});

module.exports = router;
