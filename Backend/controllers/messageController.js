const Message = require('../models/Message');

exports.saveMessage = async (req, res) => {
  try {
    const { senderId, receiverId, content, timestamp } = req.body;
    const msg = new Message({ senderId, receiverId, content, timestamp });
    await msg.save();
    res.status(200).json({ success: true, message: 'Message saved', data: msg });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

exports.getMessagesForUser = async (req, res) => {
  try {
    const userId = req.params.userId;
    const messages = await Message.find({
      $or: [{ senderId: userId }, { receiverId: userId }]
    }).sort({ timestamp: 1 });

    res.status(200).json(messages);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.params.userId;
    const count = await Message.countDocuments({ receiverId: userId, isRead: false });
    res.json({ count });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
