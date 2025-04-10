const express = require("express");
const router = express.Router();
const ParentController = require("../controllers/parentController");

// ✅ User Registration Route
router.post("/register", ParentController.register);

// ✅ User Login Route
router.post("/login", ParentController.login);

// ✅ Email Verification via Link (GET)
router.get("/verifyEmail", ParentController.verifyEmail);
// ✅ Also allow manual POST (optional)
router.post("/verifyEmail", ParentController.verifyEmail);

// ✅ Password Reset Routes
router.post("/initiatePasswordReset", ParentController.initiatePasswordReset);
router.post("/resetPassword", ParentController.resetPassword);
router.get("/verifyResetToken", ParentController.verifyResetToken);

// ✅ Export the router
module.exports = router;
