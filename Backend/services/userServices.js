require("dotenv").config();
const UserModel = require("../models/User"); // Go up two levels
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const sendEmail = require("../utils/sendEmail");
const getVerificationEmailTemplate = require("../utils/emailTemplates/verificationTemplate");
const getResetPasswordEmailTemplate = require("../utils/emailTemplates/resetPasswordTemplate");

class UserServices {
    
    // ✅ Register a new user with validation and password hashing
    static async registerUser(firstName, lastName, email, password, phone, role, dateOfBirth, address, city, zipCode) {
        try {
            console.log("----- User Registration Attempt -----", email);
    
            const existingUser = await UserModel.findOne({ email });
            if (existingUser) throw new Error("User already exists with this email!");
    
            const newUser = new UserModel({
                firstName,
                lastName,
                email,
                password,
                phone,
                role,
                dateOfBirth,
                address,
                city,
                zipCode
            });
    
            const emailToken = newUser.createEmailVerificationToken();
            await newUser.save();
    
            const verificationURL = `http://localhost:3000/api/verifyEmail?token=${emailToken}`;
            const htmlContent = getVerificationEmailTemplate(verificationURL);
            
            await sendEmail({
              to: newUser.email,
              subject: "Verify your email",
              html: htmlContent
            });
            
            return {
                message: "User registered successfully!",
                emailToken,
                user: {
                    id: newUser._id,
                    firstName: newUser.firstName,
                    lastName: newUser.lastName,
                    email: newUser.email,
                    role: newUser.role
                }
            };
        } catch (err) {
            throw err;
        }
    }
    
    // ✅ Find a user by email
    static async getUserByEmail(email) {
        try {
            return await UserModel.findOne({ email }).select("-password"); // Exclude password
        } catch (err) {
            console.log(err);
            throw err;
        }
    }

    // ✅ Check if a user exists
    static async checkUser(email) {
        try {
            return await UserModel.findOne({ email });
        } catch (error) {
            throw error;
        }
    }

    // ✅ Generate JWT Access Token
    static async generateAccessToken(tokenData, JWTSecret_Key, JWT_EXPIRE) {
        return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
    }

    // ✅ Verify email
    static async verifyEmail(token) {
        try {
            const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

            // Find user with matching verification token and check if it's expired
            const user = await UserModel.findOne({
                emailVerificationToken: hashedToken,
                emailVerificationExpires: { $gt: Date.now() }
            });

            if (!user) throw new Error("Invalid or expired verification token");

            // Mark email as verified
            user.isVerified = true;
            user.emailVerificationToken = null;
            user.emailVerificationExpires = null;
            await user.save();

            return { message: "Email verified successfully!" };
        } catch (error) {
            throw error;
        }
    }

    // ✅ Initiate Password Reset
    static async initiatePasswordReset(email) {
        try {
            const user = await UserModel.findOne({ email });
            if (!user) throw new Error("User not found!");

            // Generate password reset token
            const resetToken = user.createPasswordResetToken();
            await user.save();
            
            const resetURL = `http://localhost:3000/reset-password?token=${resetToken}`; // frontend link
            const htmlContent = getResetPasswordEmailTemplate(resetURL);
            
            await sendEmail({
              to: user.email,
              subject: "Reset your password",
              html: htmlContent,
            });
            

            return { message: "Password reset token generated!", resetToken };
        } catch (error) {
            throw error;
        }
    }

    // ✅ Reset Password
    static async resetPassword(token, newPassword) {
        try {
            const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

            // Find user with matching reset token
            const user = await UserModel.findOne({
                passwordResetToken: hashedToken,
                passwordResetExpires: { $gt: Date.now() }
            });

            if (!user) throw new Error("Invalid or expired password reset token");

            // Hash new password and update user
            user.password = newPassword; // ✅ Let model pre('save') hash it
            user.passwordResetToken = null;
            user.passwordResetExpires = null;
            await user.save();

            return { message: "Password reset successfully!" };
        } catch (error) {
            throw error;
        }
    }
}

module.exports = UserServices;
