// models/Complaint.js

const mongoose = require('mongoose');

const complaintSchema = new mongoose.Schema({
  parent_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Parent', required: true },

  caregiver_name: { type: String, required: true },
  session_type: { type: String, required: true }, // e.g. جلسة رعاية
  session_date: { type: Date, required: true },

  subject: { type: String, required: true },
  details: { type: String, required: true },

}, { timestamps: true });

module.exports = mongoose.model('Complaint', complaintSchema);
