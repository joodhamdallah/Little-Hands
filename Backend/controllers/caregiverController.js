const CaregiverServices = require("../services/caregiverServices");
const CareGiver = require('../models/CareGiver');
const BabySitter = require('../models/BabySitter');
const Expert = require('../models/Expert');


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
  exports.updateRole = async (req, res) => {
    try {
      const caregiverId = req.user._id;
      const { role } = req.body;
  
      if (!role || !["babysitter", "special_needs", "expert", "tutor"].includes(role)) {
        return res.status(400).json({ status: false, message: "Invalid role" });
      }
  
      const caregiver = await CaregiverServices.updateRoleById(caregiverId, role);
      if (!caregiver) {
        return res.status(404).json({ status: false, message: "Caregiver not found" });
      }
  
      res.status(200).json({ status: true, message: "Role updated successfully" });
    } catch (err) {
      console.error("❌ Update role error:", err);
      res.status(500).json({ status: false, message: "Internal server error" });
    }
  };
  

exports.getProfile = async (req, res) => {
  try {
    const userId = req.user._id;
    const caregiver = await CareGiver.findById(userId).select('first_name last_name image role');

    if (!caregiver) {
      return res.status(404).json({ status: false, message: "Caregiver not found" });
    }

    let profileData = {
      first_name: caregiver.first_name,
      last_name: caregiver.last_name,
      image: caregiver.image,
    };

    if (caregiver.role === 'babysitter') {
      const babysitter = await BabySitter.findOne({ user_id: userId });
      if (!babysitter) return res.status(404).json({ status: false, message: "Babysitter profile not found" });

      profileData = {
        ...profileData,
        bio: babysitter.bio,
        city: babysitter.city,
        years_experience: babysitter.years_experience,
        skills_and_services: babysitter.skills_and_services || [],
        training_certification: babysitter.training_certification || [],
        is_smoker: babysitter.is_smoker || false,
       rate_per_hour: babysitter.rate_per_hour, // ✅ Add this line

      };

    } else if (caregiver.role === 'expert') {
      const expert = await Expert.findOne({ user_id: userId });
      if (!expert) return res.status(404).json({ status: false, message: "Expert profile not found" });

      profileData = {
        ...profileData,
        bio: expert.bio,
        city: caregiver.city,
        years_experience: expert.years_of_experience || 0,
        skills_and_services: expert.session_types || [],
        training_certification: expert.categories || [],
        is_smoker: null,
        rate: expert.rate,
      };
    }

    return res.status(200).json({ status: true, profile: profileData });

  } catch (error) {
    console.error('❌ Error fetching profile:', error.message);
    res.status(500).json({ status: false, message: "Server error" });
  }
};
  
  
