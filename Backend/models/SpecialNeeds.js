const mongoose = require("mongoose");

const specialNeedsSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "CareGiver",
    required: true,
    unique: true
  },

  // Step 1: أنواع الإعاقات
  disability_experience: [String], 

  // Step 2: مؤهل أكاديمي + صورة الشهادة + سنوات الخبرة
  qualification: String, 
  certificate_image: String, 
  has_experience: Boolean,
  years_of_experience: String, 

  // Step 3: تدريبات
  trainings: [String], // مثل: "ABA"، "PECS"

  // Step 4: أعمار + مرافقة + التوفر
  preferred_age_group: String, // مثل: 7-12
  can_accompany_in_school: Boolean,
  availability: {
    type: Map,
    of: [String], // {'السبت': ['صباح', 'مساء']}
    default: {}
  },

  // Step 5: النبذة
  bio: String,

  // Step 6: السعر
  rate: {
    amount: Number,
    type: { type: String, enum: ['ساعة', 'يوم'] }
  }

}, { timestamps: true });

module.exports = mongoose.model("SpecialNeeds", specialNeedsSchema);
