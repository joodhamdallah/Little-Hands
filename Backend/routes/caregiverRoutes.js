const express = require("express");
const router = express.Router();

const caregiverController = require("../controllers/caregiverController");
const upload = require("../middleware/upload"); // multer config (upload.single("image"))

// 🟧 Register caregiver with image upload
router.post("/register", upload.single("image"), caregiverController.register);

// 🟢 Verify email via token (from link)
router.get("/verifyEmail", caregiverController.verifyEmail);

module.exports = router;
