const express = require("express");
const router = express.Router();
const auth = require("../middleware/authMiddleware");
const controller = require("../controllers/specialNeedsController");

router.post("/special-needs/details", auth, controller.saveSpecialNeedsProfile);
router.get("/special-needs/details", auth, controller.getSpecialNeedsProfile);

module.exports = router;
