const ParentServices = require("../services/parentServices");
const Parent = require('../models/Parent');

exports.register = async (req, res, next) => {
    try {
        const {
            firstName, lastName, email, password,
            phone, dateOfBirth, address, city, zipCode
        } = req.body;

        if (!firstName || !lastName || !email || !password || !phone || !dateOfBirth || !address || !city) {
            return res.status(400).json({ status: false, message: "All required fields must be provided!" });
        }

        const response = await ParentServices.registerUser({
            firstName, lastName, email, password,
            phone, dateOfBirth, address, city, zipCode
        });

        res.status(200).json({
            status: true,
            message: response.message,
        });
    }catch (err) {
        console.error("Registration Error:", err);

        // ✅ Specific error message handling
        if (err.message === "User already exists with this email!") {
            return res.status(400).json({
                status: false,
                message: "User already exists with this email!"
            });
        }
        if (err.message === "This email is already registered as a caregiver!") {
            return res.status(400).json({ status: false, message: err.message });
        }
        
        // For other unhandled errors
        next(err);
    }
};

exports.verifyEmail = async (req, res, next) => {
    try {
        const { token } = req.query;
        if (!token) return res.status(400).json({ status: false, message: "Verification token is required!" });

        const result = await ParentServices.verifyEmail(token);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Email Verification Error:", err);
        next(err);
    }
};

exports.getMe = async (req, res, next) => {
    try {
        const parent = await ParentServices.getProfile(req.user._id);

        res.status(200).json({
            success: true,
            data: {
                firstName: parent.firstName,
                lastName: parent.lastName,
                email: parent.email,
                city: parent.city,
                address: parent.address,
                phone: parent.phone,
            }
        });
    } catch (error) {
        console.error("GetMe Error:", error);
        if (error.message === "Parent not found") {
            return res.status(404).json({ success: false, message: "Parent not found" });
        }
        res.status(500).json({ success: false, message: 'Server error', error: error.message });
    }
};

exports.getParentById = async (req, res) => {
  try {
    const parent = await Parent.findById(req.params.id).select("firstName lastName");
    if (!parent) return res.status(404).json({ message: "Parent not found" });
    res.json(parent);
  } catch (error) {
    res.status(500).json({ message: "Server error", error });
  }
};


exports.updateProfile = async (req, res, next) => {
  try {
    const parentId = req.user._id;
    const { firstName, lastName, phone, address, dateOfBirth } = req.body;

    const parent = await Parent.findById(parentId);
    if (!parent) {
      return res.status(404).json({ status: false, message: "Parent not found" });
    }

    if (firstName) parent.firstName = firstName;
    if (lastName) parent.lastName = lastName;
    if (phone) parent.phone = phone;
    if (address) parent.address = address;
    if (dateOfBirth) parent.dateOfBirth = dateOfBirth;

    await parent.save();

    res.status(200).json({ status: true, message: "Profile updated successfully" });
  } catch (error) {
    console.error("Update Profile Error:", error);
    res.status(500).json({ status: false, message: "Failed to update profile", error: error.message });
  }
};
