const express = require("express");
const router = express.Router();
const AuthController = require("../controllers/authController");

// ✅ User Login Route
router.post("/login", AuthController.login);

// ✅ Password Reset Routes
router.post("/initiatePasswordReset", AuthController.initiatePasswordReset);
router.post("/resetPassword", AuthController.resetPassword);
router.get("/verifyResetToken", AuthController.verifyResetToken);

// ✅ Export the router
module.exports = router;
