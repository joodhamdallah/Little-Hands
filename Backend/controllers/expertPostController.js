const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const { summarizePDF } = require('../services/ollamaService');
const ExpertPost = require('../models/ExpertPost');

const uploadExpertPost = async (req, res) => {
  try {
    const expert_id = req.user._id; // from auth middleware
    const pdfFile = req.file;

    if (!pdfFile) return res.status(400).json({ error: 'PDF file is required' });

    const filePath = path.join(__dirname, '..', 'uploads', pdfFile.filename);
    const fileBuffer = fs.readFileSync(filePath);

    const data = await pdfParse(fileBuffer);
    const text = data.text;

    const { title, summary } = await summarizePDF(text);

    const newPost = await ExpertPost.create({
      expert_id,
      title,
      summary,
      pdf_url: `/uploads/${pdfFile.filename}`
    });

    res.status(201).json({ success: true, post: newPost });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Error uploading and processing PDF' });
  }
};

module.exports = { uploadExpertPost };
