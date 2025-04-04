const express = require("express");
const router = express.Router();
const UserController = require("../controllers/userController");

// ✅ User Registration Route
router.post("/register", UserController.register);

// ✅ User Login Route
router.post("/login", UserController.login);

// ✅ Export the router
module.exports = router;
