const Booking = require('../models/Booking');
const BabySitter = require('../models/BabySitter');
const CareGiver = require('../models/CareGiver');
const WorkSchedule = require('../models/WorkSchedule');
const NotificationService = require('./notificationService');
const sendNotification = require('../firebase/sendNotification');

class BookingService {
  static async createBooking(bookingData) {
    const {
      service_type,
      parent_id,
      caregiver_id,
      session_address_type,
      city,
      neighborhood,
      street,
      building,
      session_type,
      session_days,
      children_ages,
      has_medical_condition,
      medical_condition_details,
      takes_medicine,
      medicine_details,
      additional_notes,
      rate_min,
      rate_max,
      additional_requirements,
      consultation_topic,
      special_needs_support,
      preferred_contact_method,
      session_duration_minutes,
      schedule_id, // ⬅️ نتأكد أن هذا موجود
    } = bookingData;

    let session_start_date = bookingData.session_start_date;
    let session_start_time = bookingData.session_start_time;
    let session_end_time = bookingData.session_end_time;

    // ✅ إذا تم اختيار موعد من WorkSchedule، نقرأ تفاصيله
    if (schedule_id) {
      const selectedSlot = await WorkSchedule.findById(schedule_id);
      if (selectedSlot) {
        session_start_date = selectedSlot.date;
        session_start_time = selectedSlot.start_time;
        session_end_time = selectedSlot.end_time;

        await WorkSchedule.findByIdAndDelete(schedule_id);
        console.log(`🗑️ Deleted schedule: ${schedule_id}`);
      } else {
        console.warn(`⚠️ Schedule not found for ID: ${schedule_id}`);
      }
    }

    // ✅ إنشاء الحجز
    const newBooking = await Booking.create({
      service_type,
      parent_id,
      caregiver_id,
      session_address_type,
      city,
      neighborhood,
      street,
      building,
      session_type,
      session_start_date,
      session_end_date: bookingData.session_end_date || null,
      session_start_time,
      session_end_time,
      session_days,
      children_ages,
      has_medical_condition,
      medical_condition_details,
      takes_medicine,
      medicine_details,
      additional_notes,
      rate_min,
      rate_max,
      additional_requirements,
      consultation_topic,
      special_needs_support,
      preferred_contact_method,
      session_duration_minutes,
      status: "pending", // ✅ بشكل افتراضي
    });

    // ✅ إنشاء إشعار للجليسة
    await NotificationService.createNotification({
      user_id: caregiver_id,
      user_type: 'CareGiver',
      title: 'طلب حجز جديد',
      message: `لديك طلب حجز لخدمة ${service_type}`,
      type: 'booking_request',
      read: false,
    });
//     const babysitter = await BabySitter.findById(caregiver_id); // ❗ ID في الحجز هو ID الـ BabySitter
// console.log("🔍 Looking for babysitter with _id:", caregiver_id);


  const caregiver = await CareGiver.findById(caregiver_id); // ❗ استخدم user_id للبحث عن caregiver

  if (!caregiver) {
    console.warn("⚠️ Caregiver not found with user_id:", babysitter.user_id);
  } else {
    console.log("👤 Caregiver info:", {
      id: caregiver._id,
      name: `${caregiver.first_name} ${caregiver.last_name}`,
      email: caregiver.email,
      role: caregiver.role,
      fcm_token: caregiver.fcm_token,
      isVerified: caregiver.is_verified,
    });

    if (caregiver.fcm_token) {
      console.log("📡 Sending to token:", caregiver.fcm_token);

      await sendNotification(
        caregiver.fcm_token,
        "🔔 طلب حجز جديد",
        `لديك طلب جديد لخدمة ${service_type}`,
        {
          booking_id: newBooking._id.toString(),
          service_type,
        }
      );

      console.log("✅ FCM push notification sent");
    } else {
      console.warn("⚠️ Caregiver has no FCM token.");
    }
  }



    return newBooking;
  }
}

module.exports = BookingService;
