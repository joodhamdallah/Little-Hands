require("dotenv").config();
const CareGiverModel = require("../models/CareGiver");
const ParentModel = require("../models/Parent");
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const sendEmail = require("../utils/sendEmail");
const getVerificationEmailTemplate = require("../utils/emailTemplates/verificationTemplate");
const getResetPasswordEmailTemplate = require("../utils/emailTemplates/resetPasswordTemplate");

class CaregiverServices {
    // ✅ Register: Send email with token (don't save to DB yet)
    static async registerUser(data) {
        try {
            const existingUser = await CareGiverModel.findOne({ email: data.email });
            if (existingUser) throw new Error("User already exists with this email!");

            const parentExists = await ParentModel.findOne({ email: data.email });
            if (parentExists) throw new Error("This email is already registered as a parent!");
            
            const token = jwt.sign({ userData: data }, process.env.JWT_SECRET, { expiresIn: "5m" });
            const verificationURL = `http://localhost:3000/api/caregiver/verifyEmail?token=${token}`;
            const htmlContent = getVerificationEmailTemplate(verificationURL);

            await sendEmail({
                to: data.email,
                subject: "Verify your email",
                html: htmlContent
            });

            return {
                message: "User registered successfully, check your email for verification",
                emailToken: token
            };
        } catch (err) {
            throw err;
        }
    }

    // ✅ After clicking email: Verify and create caregiver
    static async verifyEmail(token) {
        try {
           
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            const userData = decoded.userData;
        
            const exists = await CareGiverModel.findOne({ email: userData.email });
            if (exists) {
                console.log("❌ [verifyEmail] User already exists:", exists.email);
                throw new Error("User already verified");
            }
    
            if (!userData.password) {
                console.log("❌ [verifyEmail] No password found in token payload!");
                throw new Error("Password missing from verification payload");
            }
    
            const newCaregiver = new CareGiverModel({
                ...userData,
                isVerified: true
            });
    
            await newCaregiver.save();
    
            console.log("✅ [verifyEmail] Caregiver saved:", newCaregiver.email);
    
            return { message: "Email verified and caregiver created!" };
    
        } catch (error) {
            console.error("❌ [verifyEmail] Error:", error.message);
            throw error;
        }
    }
}

module.exports = CaregiverServices;
