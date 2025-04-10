require("dotenv").config();
const ParentModel = require("../models/Parent"); // Go up two levels
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const sendEmail = require("../utils/sendEmail");
const getVerificationEmailTemplate = require("../utils/emailTemplates/verificationTemplate");
const getResetPasswordEmailTemplate = require("../utils/emailTemplates/resetPasswordTemplate");

class ParentServices {
    // ✅ Register: send verification email (do not save to DB yet)
    static async registerUser(parentData) {
        try {
            const existingUser = await ParentModel.findOne({ email: parentData.email });
            if (existingUser) throw new Error("User already exists with this email!");

            // Encode parent data inside JWT token
            const token = jwt.sign({ userData: parentData }, process.env.JWT_SECRET, { expiresIn: "5m" });

            const verificationURL = `http://localhost:3000/api/verifyEmail?token=${token}`;
            const htmlContent = getVerificationEmailTemplate(verificationURL);

            await sendEmail({
                to: parentData.email,
                subject: "Verify your email",
                html: htmlContent
            });

            return {
                message: "User registered successfully, Check your email for verification",
                emailToken: token
            };
        } catch (err) {
            throw err;
        }
    }

    // ✅ Verify email and create the parent in DB
    static async verifyEmail(token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const userData = decoded.userData;

            const existing = await ParentModel.findOne({ email: userData.email });
            if (existing) throw new Error("User already registered");

            const newUser = new ParentModel({ ...userData, isVerified: true });
            await newUser.save();

            return { message: "Email verified and user created!" };
        } catch (error) {
            throw error;
        }
    }

    // ✅ Login check
    static async checkUser(email) {
        try {
            return await ParentModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    // ✅ Fetch parent by email (excluding password)
    static async getUserByEmail(email) {
        try {
            return await ParentModel.findOne({ email }).select("-password");
        } catch (err) {
            throw err;
        }
    }

    // ✅ Generate access token
    static async generateAccessToken(tokenData, JWT_SECRET, JWT_EXPIRE) {
        return jwt.sign(tokenData, JWT_SECRET, { expiresIn: JWT_EXPIRE });
    }

    // ✅ Start reset password process
    static async initiatePasswordReset(email) {
        try {
            const user = await ParentModel.findOne({ email });
            if (!user) throw new Error("User not found!");

            const resetToken = user.createPasswordResetToken();
            await user.save();

            const resetURL = `http://localhost:3000/api/verifyResetToken?token=${resetToken}`;
            const htmlContent = getResetPasswordEmailTemplate(resetURL);

            await sendEmail({
                to: user.email,
                subject: "Reset your password",
                html: htmlContent
            });

            return { message: "Reset email sent!", resetToken };
        } catch (error) {
            throw error;
        }
    }

    // ✅ Called from the email link – verifies reset token and sets flag
    static async verifyResetToken(token) {
        try {
            const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

            const user = await ParentModel.findOne({
                passwordResetToken: hashedToken,
                passwordResetExpires: { $gt: Date.now() }
            });

            if (!user) throw new Error("Invalid or expired reset token");

            user.isResettingPassword = true;
            await user.save();

            return { message: "Token verified, you can now reset your password." };
        } catch (error) {
            throw error;
        }
    }

    // ✅ Reset password (only allowed after verification)
    static async resetPassword(email, newPassword) {
        try {
            const user = await ParentModel.findOne({ email });
            if (!user || !user.isResettingPassword) {
                throw new Error("Password reset not authorized or expired.");
            }

            user.password = newPassword;
            user.passwordResetToken = null;
            user.passwordResetExpires = null;
            user.isResettingPassword = false;
            await user.save();

            return { message: "Password reset successfully!" };
        } catch (error) {
            throw error;
        }
    }
}

module.exports = ParentServices;
