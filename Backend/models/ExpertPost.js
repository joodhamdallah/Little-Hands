const mongoose = require('mongoose');

const ExpertPostSchema = new mongoose.Schema({
  expert_id: { type: mongoose.Schema.Types.ObjectId, ref: 'CareGiver', required: true },
  title: { type: String, required: true },
  summary: { type: String, required: true },
  pdf_url: { type: String, required: true },
  created_at: { type: Date, default: Date.now },
});

module.exports = mongoose.model('ExpertPost', ExpertPostSchema);
