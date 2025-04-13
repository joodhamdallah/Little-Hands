const CaregiverServices = require("../services/caregiverServices");

exports.register = async (req, res, next) => {
    try {
        const {
            first_name, last_name, email, password,
            phone_number, date_of_birth, address, city, zip_code, gender
        } = req.body;

        // 📷 Handle image upload from multer
        const image = req.file?.path || null;

        if (!first_name || !last_name || !email || !password || !phone_number || !date_of_birth || !address || !city || !gender) {
            return res.status(400).json({ status: false, message: "All required fields must be provided!" });
        }

        const response = await CaregiverServices.registerUser({
            first_name,
            last_name,
            email,
            password,
            phone_number,
            date_of_birth,
            address,
            city,
            zip_code,
            gender,
            image // ✅ now passed to service
        });

        res.status(200).json({
            status: true,
            message: response.message,
        });
    } catch (err) {
        console.error("Caregiver Registration Error:", err);

        if (err.message === "User already exists with this email!") {
            return res.status(400).json({
                status: false,
                message: "User already exists with this email!"
            });
        }
if (err.message === "This email is already registered as a parent!") {
    return res.status(400).json({ status: false, message: err.message });
}

        next(err);
    }
};


exports.verifyEmail = async (req, res, next) => {
    try {
        const { token } = req.query;
        if (!token) return res.status(400).json({ status: false, message: "Verification token is required!" });

        const result = await CaregiverServices.verifyEmail(token);
        res.status(200).json({ status: true, message: result.message });
    } catch (err) {
        console.error("Caregiver Email Verification Error:", err);
        next(err);
    }
};

exports.checkVerificationStatus = async (req, res) => {
    try {
      const { email } = req.body;
      const result = await CaregiverServices.checkVerificationStatus(email);
  
      if (!result.found) {
        return res.status(404).json({ isVerified: false, message: "User not found" });
      }
  
      res.status(200).json({ isVerified: result.isVerified });
    } catch (error) {
      res.status(500).json({ message: "Internal server error" });
    }
  };
  
  

