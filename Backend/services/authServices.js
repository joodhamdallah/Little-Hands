const ParentModel = require("../models/Parent");
const CareGiverModel = require("../models/CareGiver");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const sendEmail = require("../utils/sendEmail");
const getResetPasswordEmailTemplate = require("../utils/emailTemplates/resetPasswordTemplate");

class AuthService {
  // ✅ Login check
  static async checkUser(email) {
    try {
      let user = await ParentModel.findOne({ email });
      if (!user) {
        user = await CareGiverModel.findOne({ email });
      }
      return user;
    } catch (error) {
      throw error;
    }
  }

  // ✅ Fetch user by email (excluding password)
  static async getUserByEmail(email) {
    try {
      let user = await ParentModel.findOne({ email }).select("-password");
      if (!user) {
        user = await CareGiverModel.findOne({ email }).select("-password");
      }
      return user;
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
      let user = await ParentModel.findOne({ email });
      let isCaregiver = false;

      if (!user) {
        user = await CareGiverModel.findOne({ email });
        isCaregiver = true;
      }

      if (!user) throw new Error("User not found!");

      const resetToken = user.createPasswordResetToken();
      await user.save();

      const resetURL = `http://localhost:3000/api/auth/verifyResetToken?token=${resetToken}`;
      const htmlContent = getResetPasswordEmailTemplate(resetURL);

      await sendEmail({
        to: user.email,
        subject: "Reset your password",
        html: htmlContent
      });

      return { message: "Reset email sent!", resetToken, isCaregiver };
    } catch (error) {
      throw error;
    }
  }

  // ✅ Called from the email link – verifies reset token and sets flag
  static async verifyResetToken(token) {
    try {
      const hashedToken = crypto.createHash("sha256").update(token).digest("hex");

      let user = await ParentModel.findOne({
        passwordResetToken: hashedToken,
        passwordResetExpires: { $gt: Date.now() }
      });

      if (!user) {
        user = await CareGiverModel.findOne({
          passwordResetToken: hashedToken,
          passwordResetExpires: { $gt: Date.now() }
        });
      }

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
      let user = await ParentModel.findOne({ email });
      if (!user) {
        user = await CareGiverModel.findOne({ email });
      }

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

module.exports = AuthService;
