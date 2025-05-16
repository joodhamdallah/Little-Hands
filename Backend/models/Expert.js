const mongoose = require("mongoose");

const degreeSchema = new mongoose.Schema({
  type: String, // بكالوريو، ماجستير، دكتوراه، ...
  specialization: String,
  institution: String,
  file_name: String,
});

const expertSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "CareGiver",
    required: true,
    unique: true
  },

  categories: [String], // استشارة سلوكية، تغذية، ...
  subcategories: [String], // مثل: نوبات الغضب، فرط الحركة ...

  degrees: [degreeSchema], // شهادات

  has_license: Boolean,
  license_authority: String,
  license_expiry: String,
  license_file_name: String,

  years_of_experience: Number,

  session_types: [String], // مثل تقييم، متابعة، استشارة أسرية
  session_method: String, // حضوري، عن بُعد، كلاهما
  age_groups: [String], // أطفال، مراهقون ...

  bio: String,
  rate: Number, // السعر للجلسة الواحدة

}, { timestamps: true });

module.exports = mongoose.model("Expert", expertSchema);
