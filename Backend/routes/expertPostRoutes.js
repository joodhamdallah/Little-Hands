const express = require('express');
const multer = require('multer');
const router = express.Router();

const {
  uploadExpertPost,
  getAllExpertPosts,
  getMyExpertPosts,
  deleteExpertPost
} = require('../controllers/expertPostController');

const authMiddleware = require('../middleware/authMiddleware');

// ✅ Multer storage setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

// ✅ Multer: Allow both pdf and image
const multiUpload = upload.fields([
  { name: 'pdf', maxCount: 1 },
  { name: 'image', maxCount: 1 } // Optional image
]);

// ✅ Upload a new PDF with optional image
router.post('/upload', authMiddleware, multiUpload, uploadExpertPost);

// ✅ Public: View all posts
router.get('/all', getAllExpertPosts);

// ✅ Authenticated expert: View own posts
router.get('/mine', authMiddleware, getMyExpertPosts);

// ✅ Authenticated expert: Delete post
router.delete('/:id', authMiddleware, deleteExpertPost);

module.exports = router;
