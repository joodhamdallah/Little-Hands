console.log("✅ identityRoutes.js loaded");

const express = require('express');
const router = express.Router();
const { verifyID } = require('../controllers/verificationController');

router.post('/verify-id', (req, res, next) => {
  console.log("✅ /api/verify-id was called");
  next();
}, verifyID);

module.exports = router;
