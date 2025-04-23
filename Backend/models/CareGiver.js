const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const crypto = require("crypto");

const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
const passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;

const careGiverSchema = new mongoose.Schema({
  first_name: { type: String, required: true, trim: true },
  last_name: { type: String, required: true, trim: true },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    match: [emailRegex, "Invalid email format"]
  },
  password: {
    type: String,
    required: true,
    minlength: 8,
    validate: {
      validator: function (value) {
        return passwordPattern.test(value);
      },
      message:
        "Password must be at least 8 characters long, include 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
    }
  },
  phone_number: { type: String, required: true, trim: true },
  date_of_birth: { type: Date, required: true },
  address: { type: String, required: true },
  city: {
    type: String,
    required: true,
    enum: ["طولكرم", "نابلس", "جنين", "رام الله", "الخليل", "غزة", "بيت لحم"]
  },
  zip_code: { type: String, default: null, trim: true },
  gender: { type: String, enum: ["ذكر", "أنثى"], required: true },
  image: { type: String, default: null },

  role: {
    type: String,
    enum: ["babysitter", "expert", "special_needs", "tutor", null],
    default: null
  },

  isVerified: { type: Boolean, default: false },
  isResettingPassword: { type: Boolean, default: false },

  emailVerificationToken: { type: String, default: null },
  emailVerificationExpires: { type: Date, default: null },

  passwordResetToken: { type: String, default: null },
  passwordResetExpires: { type: Date, default: null }
}, { timestamps: true });

careGiverSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

careGiverSchema.methods.comparePassword = async function (password) {
  console.log("🔑 [comparePassword] Incoming raw password:", password);
  console.log("🗝️  [comparePassword] Hashed password from DB:", this.password);

  const match = await bcrypt.compare(password, this.password);

  console.log("✅ [comparePassword] Password match result:", match);

  return match;
};


careGiverSchema.methods.createEmailVerificationToken = function () {
  const token = crypto.randomBytes(32).toString("hex");
  this.emailVerificationToken = crypto.createHash("sha256").update(token).digest("hex");
  this.emailVerificationExpires = Date.now() + 5 * 60 * 1000;
  return token;
};

careGiverSchema.methods.createPasswordResetToken = function () {
  const token = crypto.randomBytes(32).toString("hex");
  this.passwordResetToken = crypto.createHash("sha256").update(token).digest("hex");
  this.passwordResetExpires = Date.now() + 3 * 60 * 1000;
  return token;
};

careGiverSchema.statics.checkVerificationStatus = async function(email) {
  const user = await this.findOne({ email });
  if (!user) return { found: false, isVerified: false };
  return { found: true, isVerified: user.isVerified };
};

module.exports = mongoose.model("CareGiver", careGiverSchema);
