const BabysitterRequest = require('../models/BabysitterRequest');

exports.createRequest = async (req, res) => {
  try {
    const parentId = req.user._id;
    const requestData = { ...req.body, parent_id: parentId };
    const request = await BabysitterRequest.create(requestData);
    res.status(201).json({ success: true, data: request });
  } catch (error) {
    console.error('Error creating babysitter request:', error);
    res.status(500).json({ success: false, message: 'Failed to create request' });
  }
};

exports.getMyRequests = async (req, res) => {
  try {
    const requests = await BabysitterRequest.find({ parent_id: req.user.id }).sort({ created_at: -1 });
    res.json({ success: true, data: requests });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error fetching requests' });
  }
};

exports.deleteRequest = async (req, res) => {
  try {
    await BabysitterRequest.deleteOne({ _id: req.params.id, parent_id: req.user.id });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Delete failed' });
  }
};


exports.getRequestByParentId = async (req, res) => {
  try {
    const parentId = req.params.parentId;
    const request = await BabysitterRequest.findOne({ parent_id: parentId })
      .sort({ created_at: -1 }) // آخر طلب تم
      .lean();

    if (!request) {
      return res.status(404).json({ success: false, message: 'No request found' });
    }

    res.status(200).json({ success: true, data: request });
  } catch (error) {
    console.error("Error fetching request by parent ID:", error);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
