const express = require("express");
const router = express.Router();
const auth = require("../middleware/authMiddleware");
const controller = require("../controllers/expertController");

router.post("/experts/details", auth, controller.saveExpertProfile);
router.get("/experts/details", auth, controller.getExpertProfile);

module.exports = router;
