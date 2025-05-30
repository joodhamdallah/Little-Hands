const fs = require('fs');
const path = require('path');
const pdfParse = require('pdf-parse');
const { summarizePDF } = require('../services/openaiService'); 
const ExpertPost = require('../models/ExpertPost');

// ✅ رفع منشور خبير جديد
const uploadExpertPost = async (req, res) => {
  try {
    const expert_id = req.user._id;
    const pdfFile = req.files?.pdf?.[0];
    const imageFile = req.files?.image?.[0];

    if (!pdfFile) {
      return res.status(400).json({ success: false, message: 'ملف PDF مطلوب' });
    }

    const filePath = path.join(__dirname, '..', 'uploads', pdfFile.filename);
    const fileBuffer = fs.readFileSync(filePath);
    const data = await pdfParse(fileBuffer);

    const { title, summary } = await summarizePDF(data.text);

    const newPost = await ExpertPost.create({
      expert_id,
      title,
      summary,
      pdf_url: `/uploads/${pdfFile.filename}`,
      image_url: imageFile ? `/uploads/${imageFile.filename}` : null,
    });

    return res.status(200).json({ success: true, post: newPost });

  } catch (err) {
    console.error("❌ Error uploading expert post:", err.message);
    return res.status(500).json({ success: false, message: 'فشل في معالجة الملف' });
  }
};

// ✅ جلب كل المنشورات (لعرضها للآباء)
const getAllExpertPosts = async (req, res) => {
  try {
    const posts = await ExpertPost.find().populate('expert_id', 'first_name last_name image').sort({ created_at: -1 });
    return res.status(200).json({ success: true, posts });
  } catch (err) {
    console.error("❌ Error fetching expert posts:", err.message);
    return res.status(500).json({ success: false, message: 'فشل في جلب المنشورات' });
  }
};

// ✅ جلب منشورات الخبير المسجل حالياً
const getMyExpertPosts = async (req, res) => {
  try {
    const expert_id = req.user._id;
    const posts = await ExpertPost.find({ expert_id }).sort({ created_at: -1 });
    return res.status(200).json({ success: true, posts });
  } catch (err) {
    console.error("❌ Error fetching expert posts:", err.message);
    return res.status(500).json({ success: false, message: 'فشل في جلب منشوراتك' });
  }
};

// ✅ حذف منشور خبير
const deleteExpertPost = async (req, res) => {
  try {
    const expert_id = req.user._id;
    const postId = req.params.id;

    const post = await ExpertPost.findById(postId);
    if (!post) {
      return res.status(404).json({ success: false, message: 'المنشور غير موجود' });
    }

    if (post.expert_id.toString() !== expert_id.toString()) {
      return res.status(403).json({ success: false, message: 'غير مصرح لك بحذف هذا المنشور' });
    }

    await post.deleteOne();
    return res.status(200).json({ success: true, message: 'تم حذف المنشور بنجاح' });
  } catch (err) {
    console.error("❌ Error deleting post:", err.message);
    return res.status(500).json({ success: false, message: 'فشل في حذف المنشور' });
  }
};

module.exports = {
  uploadExpertPost,
  getAllExpertPosts,
  getMyExpertPosts,
  deleteExpertPost
};
