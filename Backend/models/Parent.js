const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const crypto = require("crypto");

const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
const passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;

const parentSchema  = new mongoose.Schema({
    firstName: { type: String, required: true, trim: true },
    lastName: { type: String, required: true, trim: true },
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
            message: "Password must be at least 8 characters long, include 1 uppercase letter, 1 lowercase letter, 1 number, and 1 special character."
        }
    },
    phone: { type: String, required: true, trim: true },
    dateOfBirth: { type: Date, required: true },
    address: { type: String, required: true },

    city: { 
        type: String, 
        required: true, 
        enum: ["طولكرم", "نابلس", "جنين", "رام الله", "الخليل", "غزة", "بيت لحم"]
    },

    zipCode: { 
        type: String, 
        default: null, 
        trim: true 
    },
  fcm_token: { type: String, default: null },

    isVerified: { type: Boolean, default: false },
    isResettingPassword: { type: Boolean, default: false },
    emailVerificationToken: { type: String, default: null },
    emailVerificationExpires: { type: Date, default: null },

    passwordResetToken: { type: String, default: null },
    passwordResetExpires: { type: Date, default: null },

    avg_rating: { type: Number, default: 0 },
    num_reviews: { type: Number, default: 0 },

}, { timestamps: true });

parentSchema.pre("save", async function (next) {
    if (!this.isModified("password")) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
});

parentSchema.methods.comparePassword = async function (password) {
    return await bcrypt.compare(password, this.password);
};

parentSchema.methods.createEmailVerificationToken = function () {
    const token = crypto.randomBytes(32).toString("hex");
    this.emailVerificationToken = crypto.createHash("sha256").update(token).digest("hex");
    this.emailVerificationExpires = Date.now() + 5 * 60 * 1000;
    return token;
};

parentSchema.methods.createPasswordResetToken = function () {
    const token = crypto.randomBytes(32).toString("hex");
    this.passwordResetToken = crypto.createHash("sha256").update(token).digest("hex");
    this.passwordResetExpires = Date.now() + 3 * 60 * 1000;
    return token;
};

module.exports = mongoose.model("Parent", parentSchema);
