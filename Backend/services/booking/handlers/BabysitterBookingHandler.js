// services/booking/handlers/BabysitterBookingHandler.js

const Booking = require('../../../models/Booking');
const WorkSchedule = require('../../../models/WorkSchedule');
const CareGiver = require('../../../models/CareGiver');
const Parent = require('../../../models/Parent');
const NotificationService = require('../../notificationService');

class BabysitterBookingHandler {
static async handle(bookingData, io) {
  const {
    parent_id,
    caregiver_id,
    service_type,
    session_address_type,
    city,
    neighborhood,
    street,
    building,
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
console.log("📦 Booking data received:", {
  session_start_date,
  session_start_time,
  session_end_time
});

  const newBooking = await Booking.create({
    parent_id,
    caregiver_id,
    service_type,
    session_address_type,
    city,
    neighborhood,
    street,
    building,
    session_start_date,
    session_end_date: session_end_date || null,
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
    status: 'pending',
  });

  await this.#notifyCaregiver(newBooking, caregiver_id, parent_id, service_type, session_start_time, city, io);
  await this.#notifyParent(newBooking, parent_id, caregiver_id, session_start_time, city, io);


  return newBooking;
}


  // static async #resolveSchedule(schedule_id, fallback) {
  //   if (!schedule_id) return fallback;

  //   const selectedSlot = await WorkSchedule.findById(schedule_id);
  //   if (selectedSlot) {
  //     await WorkSchedule.findByIdAndDelete(schedule_id);
  //     console.log(`🗑️ Deleted schedule: ${schedule_id}`);
  //     return {
  //       session_start_date: selectedSlot.date,
  //       session_start_time: selectedSlot.start_time,
  //       session_end_time: selectedSlot.end_time,
  //     };
  //   } else {
  //     console.warn(`⚠️ Schedule not found for ID: ${schedule_id}`);
  //     return fallback;
  //   }
  // }

  static async #notifyCaregiver(booking, caregiver_id, parent_id, service_type, session_time, city, io) {
    const caregiver = await CareGiver.findById(caregiver_id);
    if (!caregiver) {
      console.warn(`⚠️ Caregiver not found: ${caregiver_id}`);
      return;
    }

    const parent = await Parent.findById(parent_id);

await NotificationService.sendTypedNotification({
  user_id: caregiver_id,
  user_type: 'CareGiver',
  title: '🔔 طلب حجز جديد',
  message: `لديك طلب جديد لرعاية الأطفال.`,
  fcm_token: caregiver.fcm_token,
  type: 'booking_request',
data: {
  booking_id: booking._id.toString(),
  parent_id: parent_id.toString(),
  parent_name: `${parent?.firstName} ${parent?.lastName}`,
  session_date: booking.session_start_date?.toISOString(),
  session_start_time: booking.session_start_time,
  session_end_time: booking.session_end_time,
  city,
  neighborhood: booking.neighborhood,
  address: {
    street: booking.street,
    building: booking.building,
  },
  children_ages: booking.children_ages,
},

});

  }

    static async #notifyParent(booking, parent_id, caregiver_id, session_time, city, io) {
    const parent = await Parent.findById(parent_id);
    const caregiver = await CareGiver.findById(caregiver_id);

    if (!parent) {
      console.warn(`⚠️ Parent not found: ${parent_id}`);
      return;
    }

  await NotificationService.sendTypedNotification({
  user_id: parent_id,
  user_type: 'Parent',
  title: '📅 تم إرسال طلبك بنجاح',
  message: `تم إرسال طلبك إلى الجليسة ${caregiver?.first_name ?? ''}.`,
  fcm_token: parent.fcm_token,
  type: 'booking_request',
data: {
  booking_id: booking._id.toString(),
  parent_id: parent_id.toString(),
  caregiver_id: caregiver_id.toString(),
  caregiver_name: `${caregiver?.first_name ?? ''} ${caregiver?.last_name ?? ''}`,
  session_date: booking.session_start_date?.toISOString(),
  session_start_time: booking.session_start_time,
  session_end_time: booking.session_end_time,
  city,
  neighborhood: booking.neighborhood,
  address: {
    street: booking.street,
    building: booking.building,
  },
  children_ages: booking.children_ages,
},
});

  }
}

module.exports = BabysitterBookingHandler;
