const CaregiverServices = require("../services/caregiverServices");
const CareGiver = require('../models/CareGiver');
const BabySitter = require('../models/BabySitter');
const Expert = require('../models/Expert');
const Booking = require('../models/Booking');
const Feedback = require('../models/Feedback');


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
// After setting profileData
const today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"
// let totalBookings = 0;
// let totalFeedbacks = 0;
// let averageRating = 0;
// let todaySessions = 0;
  if (caregiver.role === 'babysitter') {
     const babysitter = await BabySitter.findOne({ user_id: userId });
if (!babysitter) {
  return res.status(404).json({ status: false, message: "Babysitter profile not found" });
}

// Fetch only confirmed/completed bookings
const bookings = await Booking.find({
  caregiver_id: userId,
  service_type: 'babysitter',
  status: { $in: ['confirmed', 'completed'] },
});

// Calculate totals from price_details
const totalBookings = bookings.length;
const totalIncome = bookings.reduce((sum, b) => sum + (b.price_details?.total || 0), 0);
const averageSessionRate = totalBookings > 0 ? totalIncome / totalBookings : 0;

// Count today's sessions
const today = new Date().toISOString().split('T')[0];
const todaySessions = await Booking.countDocuments({
  caregiver_id: userId,
  session_start_date: today,
  service_type: 'babysitter',
  status: { $in: ['confirmed', 'completed'] },
});

// Weekly chart data
const now = new Date();
const weeksAgo = new Date(now);
weeksAgo.setDate(weeksAgo.getDate() - 28);
const recentBookings = await Booking.find({
  caregiver_id: userId,
  service_type: 'babysitter',
  session_start_date: { $gte: weeksAgo.toISOString().split('T')[0] },
  status: { $in: ['confirmed', 'completed'] },
});
const sessionCounts = [0, 0, 0, 0];
for (const b of recentBookings) {
  const sessionDate = new Date(b.session_start_date);
  const diffDays = Math.floor((now - sessionDate) / (1000 * 60 * 60 * 24));
  const weekIndex = Math.floor(diffDays / 7);
  if (weekIndex >= 0 && weekIndex < 4) sessionCounts[3 - weekIndex] += 1;
}
const sessions_chart = [
  { week: '1-7', count: sessionCounts[0] },
  { week: '8-14', count: sessionCounts[1] },
  { week: '15-21', count: sessionCounts[2] },
  { week: '22-28', count: sessionCounts[3] },
];

// Get today session details
const todaySessionDetails = await Booking.findOne({
  caregiver_id: userId,
  session_start_date: today,
  service_type: 'babysitter',
  status: { $in: ['confirmed', 'completed'] },
})
  .sort({ session_start_time: 1 })
  .populate('parent_id', 'firstName lastName image')
  .lean();

let todaySessionInfo = null;
if (todaySessionDetails) {
  todaySessionInfo = {
    time: {
      start: todaySessionDetails.session_start_time,
      end: todaySessionDetails.session_end_time,
    },
    children_ages: todaySessionDetails.children_ages || [],
    address: {
      type: todaySessionDetails.session_address_type,
      city: todaySessionDetails.city,
      neighborhood: todaySessionDetails.neighborhood,
      street: todaySessionDetails.street,
      building: todaySessionDetails.building,
    },
    payment: {
      method: todaySessionDetails.payment_method,
      status: todaySessionDetails.payment_status,
      price_details: todaySessionDetails.price_details || null,
    },
    parent: todaySessionDetails.parent_id
      ? {
          first_name: todaySessionDetails.parent_id.firstName,
          last_name: todaySessionDetails.parent_id.lastName,
          image: todaySessionDetails.parent_id.image || null,
        }
      : null,
  };
}

// Get top-rated feedback
const topFeedback = await Feedback.findOne({
  to_user_id: userId,
  type: 'completed',
  from_role: 'parent', // Important for refPath
  ratings: { $exists: true, $ne: [] },
    comments: { $exists: true, $ne: {} } // ✅ Ensures comments not empty

})
.sort({ overall_rating: -1, created_at: -1 })
  .populate({
    path: 'from_user_id',
    select: 'firstName lastName image',
    model: 'Parent' // explicitly specify the model due to refPath
  });
  
let topComments = [];

if (topFeedback && topFeedback.ratings && topFeedback.comments) {
  let ratingsObj = {};
  let commentsObj = {};

  if (topFeedback.ratings instanceof Map) {
    ratingsObj = Object.fromEntries(topFeedback.ratings.entries());
  } else if (typeof topFeedback.ratings === 'object') {
    ratingsObj = { ...topFeedback.ratings };
  }

  if (topFeedback.comments instanceof Map) {
    commentsObj = Object.fromEntries(topFeedback.comments.entries());
  } else if (typeof topFeedback.comments === 'object') {
    commentsObj = { ...topFeedback.comments };
  }

  console.log("🔍 ratingsObj:", ratingsObj);
  console.log("🔍 commentsObj:", commentsObj);

  // ✅ Now entries will be clean
  const ratingEntries = Object.entries(ratingsObj);

  const filteredEntries = ratingEntries.filter(([key, val]) => {
    const comment = commentsObj[key];
    const pass = comment !== undefined && comment !== null && comment !== '' && typeof val === 'number';
    console.log(`🔎 key: ${key}, val: ${val}, comment: ${comment}, pass: ${pass}`);
    return pass;
  });

  console.log("✅ Filtered rating entries with comments:", filteredEntries);

  topComments = filteredEntries
    .sort((a, b) => b[1] - a[1])
    .slice(0, 2)
    .map(([key]) => ({
      question: key,
      comment: commentsObj[key]
    }));
}

console.log("🧪 Top comments (final):", topComments);

profileData = {
  ...profileData,
  bio: babysitter.bio,
  city: babysitter.city,
  years_experience: babysitter.years_experience,
  skills_and_services: babysitter.skills_and_services || [],
  training_certification: babysitter.training_certification || [],
  is_smoker: babysitter.is_smoker || false,
  rate_per_hour: babysitter.rate_per_hour,
  totalBookings,
  totalIncome,
  averageSessionRate,
  totalFeedbacks: babysitter.ratings_count ?? 0,
  averageRating: babysitter.average_rating ?? 0,
  todaySessions,
  sessions_chart,
  today_session_info: todaySessionInfo,
highlighted_feedback: topFeedback
  ? {
      overall_rating: topFeedback.overall_rating,
comments: topComments,
      from_user: {
        first_name: topFeedback.from_user_id?.firstName || '',
        last_name: topFeedback.from_user_id?.lastName || '',
        image: topFeedback.from_user_id?.image || null,
      }
    }
  : null,
};

    }  else if (caregiver.role === 'expert') {
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
  
  
