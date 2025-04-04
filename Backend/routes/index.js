const express = require("express");
const router = express.Router();

// Example Route
router.get("/", (req, res) => {
    res.send("Hello, MongoDB is connected!");
});

module.exports = router;
