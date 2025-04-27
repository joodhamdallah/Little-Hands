require("dotenv").config();
const ParentModel = require("../models/Parent"); // Go up two levels
const CareGiverModel = require("../models/CareGiver");
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

            const caregiverExists = await CareGiverModel.findOne({ email: parentData.email });
            if (caregiverExists) throw new Error("This email is already registered as a caregiver!");
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

    // ✅ Get Parent Profile by ID
static async getProfile(parentId) {
    try {
    // console.log("user id="+parentId);
        const parent = await ParentModel.findById(parentId);
        if (!parent) {
            throw new Error("Parent not found");
        }
        return parent;
    } catch (error) {
        throw error;
    }
}

}

module.exports = ParentServices;
