const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  parent_id: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Parent', 
    required: true 
  },

  caregiver_id: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'CareGiver', 
    required: true 
  },

  // 👑 نوع الخدمة المطلوبة
  service_type: { 
    type: String, 
    enum: ['babysitter', 'consultant', 'special_needs', 'tutor'], 
    required: true 
  },

  // 🏡 موقع الجلسة (خاص بالجليسة مثلا)
  session_address_type: { type: String },
  city: { type: String },
  neighborhood: { type: String },
  street: { type: String },
  building: { type: String },

  // 🕒 وقت الجلسة
  session_start_date: { type: Date },
  session_end_date: { type: Date },
  session_start_time: { type: String },
  session_end_time: { type: String },
  session_days: [{ type: String }],

  // 👶 تفاصيل الأطفال (للجليسة)
  children_ages: [{ type: String }],
  has_medical_condition: { type: Boolean },
  medical_condition_details: { type: String },
  takes_medicine: { type: Boolean },
  medicine_details: { type: String },

  // 🗒️ ملاحظات إضافية
  additional_notes: { type: String },

  // 💸 السعر
  rate_min: { type: Number },
  rate_max: { type: Number },

  // 🧩 متطلبات إضافية
  additional_requirements: [{ type: String }],

  // 🧠 للاستشاريين والاحتياجات الخاصة
  consultation_topic: { type: String },
  special_needs_support: { type: String },
  preferred_contact_method: { type: String, enum: ['video', 'phone', 'chat'] },
  session_duration_minutes: { type: Number },

  // ✅ حالة الطلب
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected'],
    default: 'pending'
  },

  meeting_link: {
  type: String,
  default: null,
},


}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
