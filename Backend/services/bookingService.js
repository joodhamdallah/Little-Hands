const Booking = require('../models/Booking');
const BabySitter = require('../models/BabySitter');
const CareGiver = require('../models/CareGiver');
const NotificationService = require('../services/notificationService');
const sendNotification = require('../firebase/sendNotification'); // ✅ استدعاء الملف

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
      session_start_date,
      session_end_date,
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
    } = bookingData;

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
      session_end_date,
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
    });

    // ⏰ Send notification to the caregiver
    await NotificationService.createNotification({
      user_id: caregiver_id,
      user_type: 'CareGiver', // ✅ Add this line

      title: 'طلب حجز جديد',
      message: `لديك طلب حجز لخدمة ${service_type}`,
      type: 'booking_request',
      read: false,
    });
    const babysitter = await BabySitter.findById(caregiver_id); // ❗ ID في الحجز هو ID الـ BabySitter

if (babysitter) {
  const caregiver = await CareGiver.findById(babysitter.user_id); // ❗ استخدم user_id للبحث عن caregiver

  if (caregiver && caregiver.fcm_token) {
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
  }
}

    return newBooking;
  }
}

module.exports = BookingService;
