const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");

// ✅ User Registration Route
router.post("/register", UserController.register);

// ✅ User Login Route
router.post("/login", UserController.login);

// ✅ Email Verification via Link (GET)
router.get("/verifyEmail", UserController.verifyEmail);
// ✅ Also allow manual POST (optional)
router.post("/verifyEmail", UserController.verifyEmail);

// ✅ Password Reset Routes
router.post("/initiatePasswordReset", UserController.initiatePasswordReset);
router.post("/resetPassword", UserController.resetPassword);
// ✅ Export the router
module.exports = router;
