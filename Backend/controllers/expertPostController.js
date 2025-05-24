const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const { summarizePDF } = require('../services/ollamaService');
const ExpertPost = require('../models/ExpertPost');

const uploadExpertPost = async (req, res) => {
  try {
    const expert_id = req.user._id;
    const files = req.files;

    const pdfFile = files?.pdf?.[0];
    const imageFile = files?.image?.[0];

    if (!pdfFile) return res.status(400).json({ error: 'PDF file is required' });

    const pdfPath = path.join(__dirname, '..', 'uploads', pdfFile.filename);
    const pdfBuffer = fs.readFileSync(pdfPath);

    const data = await pdfParse(pdfBuffer);
    const text = data.text;

    const { title, summary } = await summarizePDF(text);

    const newPost = await ExpertPost.create({
      expert_id,
      title,
      summary,
      pdf_url: `/uploads/${pdfFile.filename}`,
      image_url: imageFile ? `/uploads/${imageFile.filename}` : null
    });

    res.status(201).json({ success: true, post: newPost });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Error uploading and processing post' });
  }
};



const getAllExpertPosts = async (req, res) => {
  try {
    const posts = await ExpertPost.find().sort({ created_at: -1 });
    res.json({ success: true, posts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Failed to fetch expert posts" });
  }
};

const getMyExpertPosts = async (req, res) => {
  try {
    const expert_id = req.user._id;
    const posts = await ExpertPost.find({ expert_id }).sort({ created_at: -1 });
    res.json({ success: true, posts });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Failed to fetch your posts" });
  }
};

const deleteExpertPost = async (req, res) => {
  try {
    const postId = req.params.id;
    const userId = req.user._id;

    const post = await ExpertPost.findById(postId);
    if (!post) {
      return res.status(404).json({ success: false, message: "Post not found" });
    }

    if (post.expert_id.toString() !== userId.toString()) {
      return res.status(403).json({ success: false, message: "Unauthorized" });
    }

    // Delete the PDF file
    const filePath = path.join(__dirname, '..', post.pdf_url);
    if (fs.existsSync(filePath)) fs.unlinkSync(filePath);

    await post.deleteOne();

    res.json({ success: true, message: "Post deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, message: "Failed to delete post" });
  }
};

module.exports = {
  uploadExpertPost,
  getAllExpertPosts,
  getMyExpertPosts,
  deleteExpertPost
};
