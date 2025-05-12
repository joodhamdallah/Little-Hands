const AuthService = require("../services/authServices");
const Parent = require('../models/Parent');
const CareGiver = require('../models/CareGiver');

exports.login = async (req, res, next) => {
    try {
        console.log("--- User Login Request ---", req.body);
        const { email, password, rememberMe } = req.body;

        if (!email || !password) {
            return res.status(400).json({ status: false, message: "Email and password are required!" });
        }

        const userResult = await AuthService.checkUser(email);
        if (!userResult) {
          return res.status(404).json({ status: false, message: "User does not exist!, register now" });
        }
        const { user, type } = userResult;

        const isPasswordCorrect = await user.comparePassword(password);
        if (!isPasswordCorrect) {
            return res.status(401).json({ status: false, message: "Incorrect email or password!" });
        }

        if (!user.isVerified) {
            return res.status(403).json({ status: false, message: "Email not verified. Please check your inbox." });
        }

        const expiresIn = rememberMe ? "7d" : "1h";
        const tokenData = { _id: user._id, email: user.email, role: user.role || "parentOrCaregiver" };
        const token = await AuthService.generateAccessToken(tokenData, process.env.JWT_SECRET, expiresIn);

        res.status(200).json({
            status: true,
            message: "Login successful!",
            token,
            expiresIn,
            user: {
                id: user._id,
                email: user.email,
                role: user.role || null,
                type,
                firstName: user.firstName || user.first_name,
                lastName: user.lastName || user.last_name,
            }
        });

    } catch (error) {
        console.error("Login Error --->", error);
        next(error);
    }
};

exports.initiatePasswordReset = async (req, res, next) => {
    try {
        const { email } = req.body;
        if (!email) {
            return res.status(400).json({ status: false, message: "Email is required!" });
        }

        const result = await AuthService.initiatePasswordReset(email);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Initiate Password Reset Error:", err);
        next(err);
    }
};

exports.verifyResetToken = async (req, res, next) => {
    try {
        const { token } = req.query;
        if (!token) {
            return res.status(400).json({ status: false, message: "Reset token is required!" });
        }

        const result = await AuthService.verifyResetToken(token);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Verify Reset Token Error:", err);
        next(err);
    }
};

exports.resetPassword = async (req, res, next) => {
    try {
        const { email, newPassword } = req.body;
        if (!email || !newPassword) {
            return res.status(400).json({ status: false, message: "Email and new password are required!" });
        }

        const result = await AuthService.resetPassword(email, newPassword);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Password Reset Error:", err);
        return res.status(400).json({
            status: false,
            message: err.message || "Something went wrong"
        });
    }
};

exports.saveFcmToken = async (req, res) => {
  try {
    const { fcm_token } = req.body;
    if (!fcm_token) {
      return res.status(400).json({ status: false, message: "FCM token is required" });
    }

    const userId = req.user._id;

    // Try caregiver first
    const caregiver = await CareGiver.findById(userId);
    if (caregiver) {
      caregiver.fcm_token = fcm_token;
      await caregiver.save();
      return res.status(200).json({ status: true, message: "FCM token saved (caregiver)" });
    }

    // Try parent next
    const parent = await Parent.findById(userId);
    if (parent) {
      parent.fcm_token = fcm_token;
      await parent.save();
      return res.status(200).json({ status: true, message: "FCM token saved (parent)" });
    }

    return res.status(404).json({ status: false, message: "User not found" });

  } catch (error) {
    console.error("❌ Error saving FCM token:", error.message);
    return res.status(500).json({ status: false, message: "Server error" });
  }
};