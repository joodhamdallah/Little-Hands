const express = require("express");
const router = express.Router();
const ParentController = require("../controllers/parentController");

// ✅ User Registration Route
router.post("/register", ParentController.register);

// ✅ Email Verification via Link (GET)
router.get("/verifyEmail", ParentController.verifyEmail);

// ✅ Export the router
module.exports = router;
