const express = require("express");
const router = express.Router();
const AuthController = require("../controllers/authController");
const authMiddleware = require("../middleware/authMiddleware"); 

// ✅ User Login Route
router.post("/login", AuthController.login);

// ✅ Password Reset Routes
router.post("/initiatePasswordReset", AuthController.initiatePasswordReset);
router.post("/resetPassword", AuthController.resetPassword);
router.get("/verifyResetToken", AuthController.verifyResetToken);

router.post('/save-fcm-token', authMiddleware, AuthController.saveFcmToken); // ✅ unified for both roles

// ✅ Export the router
module.exports = router;
