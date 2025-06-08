const express = require("express");
const router = express.Router();
const ParentController = require("../controllers/parentController");
const authMiddleware = require('../middleware/authMiddleware');

// ✅ User Registration Route
router.post("/register", ParentController.register);

// ✅ Email Verification via Link (GET)
router.get("/verifyEmail", ParentController.verifyEmail);

router.get('/me', authMiddleware, ParentController.getMe);
 
router.get("/parentprof/:id", ParentController.getParentById); // /api/parents/:id


// ✅ Export the router
module.exports = router;
