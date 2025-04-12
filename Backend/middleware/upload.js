const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Ensure uploads folder exists
const folder = "uploads/caregivers";
if (!fs.existsSync(folder)) {
    fs.mkdirSync(folder, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, folder);
    },
    filename: function (req, file, cb) {
        const ext = path.extname(file.originalname).toLowerCase();
        const uniqueName = Date.now() + "-" + Math.round(Math.random() * 1e9) + ext;
        cb(null, uniqueName);
    }
});

// Allow only images
const fileFilter = (req, file, cb) => {
    const allowedMimeTypes = ["image/jpeg", "image/jpg", "image/png", "image/webp"];
    const allowedExt = [".jpg", ".jpeg", ".png", ".webp"];
  
    const ext = path.extname(file.originalname).toLowerCase();
    const mime = file.mimetype;
  
    if (allowedMimeTypes.includes(mime) || (mime === "application/octet-stream" && allowedExt.includes(ext))) {
      cb(null, true); // ✅ allow .jpg even if mimetype is bad
    } else {
      console.log("⛔ Blocked file upload:", file.originalname, file.mimetype);
      cb(new Error("Only image files (jpeg, png, webp) are allowed!"));
    }
  };
  
  

// Configure multer
const upload = multer({
    storage,
    fileFilter,
    limits: { fileSize: 5 * 1024 * 1024 } // 5MB max size
});

module.exports = upload;
