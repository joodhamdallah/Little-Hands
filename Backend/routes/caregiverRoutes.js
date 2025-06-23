const express = require("express");
const router = express.Router();

const caregiverController = require("../controllers/caregiverController");
const upload = require("../middleware/upload"); // multer config (upload.single("image"))
const authMiddleware = require("../middleware/authMiddleware"); // ✅ استدعاء الميدلوير

// 🟧 Register caregiver with image upload
router.post("/register", upload.single("image"), caregiverController.register);

// 🟢 Verify email via token (from link)
router.get("/verifyEmail", caregiverController.verifyEmail);
router.post('/checkVerificationStatus', caregiverController.checkVerificationStatus);

router.post("/updateRole", authMiddleware, caregiverController.updateRole);


router.get('/profile', authMiddleware, caregiverController.getProfile);

router.get('/nearby-city', authMiddleware, caregiverController.getCaregiversInSameCity);

// GET /caregivers/by-role/:role
router.get('/by-role/:role', caregiverController.getCaregiversByRole);


module.exports = router;
