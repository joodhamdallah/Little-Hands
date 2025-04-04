const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const crypto = require("crypto"); // For generating secure tokens

// Email validation regex
const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

// Strong password validation regex
const passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$/;

const userSchema = new mongoose.Schema({
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
    role: { 
        type: String, 
        enum: ["admin", "parent", "expert", "specialist"], 
        default: "parent" 
    },
    dateOfBirth: { type: Date, required: true },
    address: { type: String, required: true },

    // ✅ Email Verification Fields
    isVerified: { type: Boolean, default: false },
    emailVerificationToken: { type: String, default: null },
    emailVerificationExpires: { type: Date, default: null },

    // ✅ Password Reset Fields
    passwordResetToken: { type: String, default: null },
    passwordResetExpires: { type: Date, default: null },

}, { timestamps: true }); // Adds createdAt and updatedAt fields

// ✅ Hash password before saving
userSchema.pre("save", async function (next) {
    console.log("you got here ");  // Log the plain password provided by the user

    if (!this.isModified("password")) return next();
    this.password = await bcrypt.hash(this.password, 10);
    next();
});

// ✅ Compare passwords for login
userSchema.methods.comparePassword = async function (password) {
    console.log("Plain Password: ", password);  // Log the plain password provided by the user
    console.log("Hashed Password: ", this.password);  // Log the stored hashed password in the database
    
    const match = await bcrypt.compare(password, this.password);
    console.log("Password Match Status: ", match);  // Log if the password matched
    
    return match;
};

// ✅ Generate Email Verification Token
userSchema.methods.createEmailVerificationToken = function () {
    const token = crypto.randomBytes(32).toString("hex");
    this.emailVerificationToken = crypto.createHash("sha256").update(token).digest("hex");
    this.emailVerificationExpires = Date.now() + 10 * 60 * 1000; // Expires in 10 minutes
    return token; // Return raw token to send via email
};

// ✅ Generate Password Reset Token
userSchema.methods.createPasswordResetToken = function () {
    const token = crypto.randomBytes(32).toString("hex");
    this.passwordResetToken = crypto.createHash("sha256").update(token).digest("hex");
    this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // Expires in 10 minutes
    return token; // Return raw token to send via email
};

module.exports = mongoose.model("User", userSchema);
