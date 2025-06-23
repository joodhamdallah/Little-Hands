// controllers/complaintController.js

const Complaint = require('../models/Complaint');
const Parent = require('../models/Parent');

exports.submitComplaint = async (req, res) => {
  try {
    const { caregiver_name, session_type, session_date, subject, details } = req.body;
    const parentId = req.user._id;

    if (!caregiver_name || !session_type || !session_date || !subject || !details) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const complaint = new Complaint({
      parent_id: parentId,
      caregiver_name,
      session_type,
      session_date,
      subject,
      details,
    });

    await complaint.save();

    res.status(201).json({ success: true, message: 'Complaint submitted successfully' });
  } catch (err) {
    console.error('❌ Error submitting complaint:', err);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
exports.getAllComplaints = async (req, res) => {
  try {
    const complaints = await Complaint.find()
      .populate({
        path: 'parent_id',
        select: 'firstName lastName email city',
        model: 'Parent',
      })
      .sort({ createdAt: -1 });

    const formatted = complaints.map(c => ({
      caregiver_name: c.caregiver_name,
      session_type: c.session_type,
      session_date: c.session_date,
      subject: c.subject,
      details: c.details,
      parent: c.parent_id ? {
        full_name: `${c.parent_id.firstName} ${c.parent_id.lastName}`,
        email: c.parent_id.email,
        city: c.parent_id.city,
      } : null,
    }));

    res.json({ success: true, data: formatted });
  } catch (err) {
    console.error('❌ Error fetching complaints:', err);
    res.status(500).json({ success: false, message: 'فشل في جلب الشكاوى' });
  }
};