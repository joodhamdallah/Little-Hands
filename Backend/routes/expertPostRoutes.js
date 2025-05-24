const express = require('express');
const multer = require('multer');
const { uploadExpertPost } = require('../controllers/expertPostController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => cb(null, Date.now() + '-' + file.originalname)
});
const upload = multer({ storage });

router.post('/upload', authMiddleware, upload.single('pdf'), uploadExpertPost);

module.exports = router;
