// services/booking/handlers/BabysitterBookingHandler.js
const Booking = require('../../../models/Booking');
const CareGiver = require('../../../models/CareGiver');
const Parent = require('../../../models/Parent');
const NotificationService = require('../../notificationService');
const { v4: uuidv4 } = require('uuid'); 
const sendEmail = require('../../../utils/sendEmail');
const {
  getParentMeetingEmail,
  getBabysitterMeetingEmail
} = require('../../../utils/emailTemplates/meetingLinkTemplates');
const CancellationStats = require('../../../models/CancellationStats');
const FallbackService = require('../../fallbackService');

class BabysitterBookingHandler {
  static async createBooking(bookingData, io) {
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
      session_end_datetime:null,  // ✅ Explicitly set

    });

    await this.#notifyCaregiver(newBooking, caregiver_id, parent_id, service_type, session_start_time, city,io);
    await this.#notifyParent(newBooking, parent_id, caregiver_id, session_start_time, city,io);

    return newBooking;
  }

  static async confirmBooking(bookingId, io) {
    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { status: 'confirmed' },
      { new: true }
    );
    if (!updated) throw new Error('Booking not found');

    io.to(updated.parent_id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: updated._id.toString(),
      status: 'confirmed',
    });

    return updated;
  }

  static async rejectBooking(bookingId) {
    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { status: 'rejected' },
      { new: true }
    );
    if (!updated) throw new Error('Booking not found');
    return updated;
  }

   static async acceptBooking(bookingId, io) {
    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { status: 'accepted' },
      { new: true }
    );
    if (!updated) throw new Error('Booking not found');
io.to(updated.parent_id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: updated._id.toString(),
      status: 'accepted',
    });
    const caregiver = await CareGiver.findById(updated.caregiver_id);
    const parent = await Parent.findById(updated.parent_id);

    // 🎯 Notify Parent
    await NotificationService.sendTypedNotification({
      user_id: updated.parent_id.toString(),
      user_type: 'Parent',
      title: '✅ تم قبول الحجز',
      message: `${caregiver?.first_name ?? 'المقدم'} قبل حجز الجلسة.`,
      fcm_token: parent?.fcm_token,
      type: 'booking_accepted',
      data: {
        booking_id: updated._id.toString(),
        status: 'accepted',
      },
    });

    // 🎯 Notify Caregiver (confirmation for themselves)
    await NotificationService.sendTypedNotification({
      user_id: updated.caregiver_id.toString(),
      user_type: 'CareGiver',
      title: '👍 تم قبول الحجز',
      message: `تم قبولك للحجز بنجاح.`,
      fcm_token: caregiver?.fcm_token,
      type: 'booking_accepted',
      data: {
        booking_id: updated._id.toString(),
        status: 'accepted',
      },
    });

    // 📡 Real-time update
    io.to(updated.parent_id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: updated._id.toString(),
      status: 'accepted',
    });
    io.to(updated.caregiver_id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: updated._id.toString(),
      status: 'accepted',
    });

    return updated;
  }


  static async bookMeeting(bookingId, meetingData, io) {
    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    const meetingLink = `https://meet.jit.si/LittleHands-${uuidv4()}`;

    booking.status = 'meeting_booked';
    booking.meeting_slot_id = meetingData.meeting_schedule_id;
    booking.meeting_link = meetingLink;

    await booking.save();

    const caregiver = await CareGiver.findById(booking.caregiver_id);
    const parent = await Parent.findById(booking.parent_id);

    const message = `📅 تم حجز اجتماع بتاريخ ${booking.session_start_date.toISOString().split('T')[0]}، من ${booking.session_start_time} إلى ${booking.session_end_time}`;

    await NotificationService.sendTypedNotification({
      user_id: parent._id.toString(),
      user_type: 'Parent',
      title: '📞 تم حجز موعد اجتماع',
      message: message,
      fcm_token: parent.fcm_token,
      type: 'meeting_booked',
      data: {
        booking_id: booking._id.toString(),
        meeting_link: booking.meeting_link,
        status: 'meeting_booked',
      },
    });

    await NotificationService.sendTypedNotification({
      user_id: caregiver._id.toString(),
      user_type: 'CareGiver',
      title: '📞 تم حجز موعد اجتماع',
      message: message,
      fcm_token: caregiver.fcm_token,
      type: 'meeting_booked',
      data: {
        booking_id: booking._id.toString(),
        meeting_link: booking.meeting_link,
        status: 'meeting_booked',
      },
    });

    io.to(parent._id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: booking._id.toString(),
      status: 'meeting_booked',
    });
    io.to(caregiver._id.toString()).emit('newNotification', {
      type: 'booking_status_updated',
      booking_id: booking._id.toString(),
      status: 'meeting_booked',
    });
// 📨 Send meeting emails
const meetingDate = booking.session_start_date.toISOString().split('T')[0];
const meetingTime = `${booking.session_start_time} - ${booking.session_end_time}`;

// Email to parent
await sendEmail({
  to: parent.email,
  subject: '📞 Your Babysitting Meeting is Scheduled',
  html: getParentMeetingEmail(meetingLink, meetingDate, meetingTime, caregiver.first_name),
});

// Email to babysitter
await sendEmail({
  to: caregiver.email,
  subject: '📞 Meeting Scheduled with Parent',
  html: getBabysitterMeetingEmail(meetingLink, meetingDate, meetingTime, parent.firstName),
});
    return booking;
  }


static async cancelBooking(bookingId, cancelledBy, reason = null, io) {
  const booking = await Booking.findById(bookingId);
  if (!booking) throw new Error('Booking not found');

  const currentStage = booking.status; // e.g., 'pending', 'accepted', etc.
  const userField = cancelledBy === 'parent' ? 'parent_id' : 'caregiver_id';
  const userId = booking[userField];

  // 🔄 Update booking status
  booking.status = 'cancelled';
  booking.cancelled_by = cancelledBy;
  booking.cancellation_reason = reason || null;
  booking.cancelled_at_stage = currentStage;
  booking.cancelled_at = new Date();

  console.log('❌ Booking cancelled at stage:', currentStage);

  await booking.save();

  // ✅ Check for fallback trigger
if (cancelledBy === 'caregiver' && currentStage === 'confirmed') {
  console.log('🔔 Triggering fallback offer logic...');
  await FallbackService.broadcastFallbackOffer(booking, io);
  
}

  // ✅ Update cancellation stats in the new collection
  await CancellationStats.findOneAndUpdate(
    { user_id: userId, role: cancelledBy },
    {
      $inc: {
        [`stats.${currentStage}`]: 1,
        'stats.total': 1,
      },
    },
    { upsert: true, new: true }
  );

  // 📡 Emit socket notifications
  io.to(booking.parent_id.toString()).emit('newNotification', {
    type: 'booking_status_updated',
    booking_id: booking._id.toString(),
    status: 'cancelled',
  });
  io.to(booking.caregiver_id.toString()).emit('newNotification', {
    type: 'booking_status_updated',
    booking_id: booking._id.toString(),
    status: 'cancelled',
  });

  return booking;
}

  static async markCompleted(bookingId) {
    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { status: 'completed' },
      { new: true }
    );
    if (!updated) throw new Error('Booking not found');
    return updated;
  }

  static async markAsPaid(bookingId) {
    const updated = await Booking.findByIdAndUpdate(
      bookingId,
      { payment_status: 'paid' },
      { new: true }
    );
    if (!updated) throw new Error('Booking not found');
    return updated;
  }

  static async #notifyCaregiver(booking, caregiver_id, parent_id, service_type, session_time, city,io) {
    const caregiver = await CareGiver.findById(caregiver_id);
    if (!caregiver) return;

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

  static async #notifyParent(booking, parent_id, caregiver_id, session_time, city,io) {
    const parent = await Parent.findById(parent_id);
    const caregiver = await CareGiver.findById(caregiver_id);
    if (!parent) return;

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

   static async setPrice(bookingId, priceData) {
    const {
      is_hourly,
      hourly_rate,
      fixed_rate,
      session_hours,
      subtotal,
      total,
      additional_fees,
    } = priceData;

    const booking = await Booking.findById(bookingId);
    if (!booking) throw new Error('Booking not found');

    booking.price_details = {
      is_hourly,
      hourly_rate,
      fixed_rate,
      session_hours,
      subtotal,
      total,
      additional_fees,
    };

    await booking.save();
    return { status: true, message: 'Price saved successfully' };
  }
static async setPaymentMethod(bookingId, method, io) {
  console.log('🚀 setPaymentMethod called with:', { bookingId, method });

  const booking = await Booking.findById(bookingId);
  if (!booking) {
    console.error('❌ Booking not found in DB');
    throw new Error('Booking not found');
  }
  console.log('📦 Booking found:', booking._id.toString());

  const sessionDateStr = booking.session_start_date.toISOString().split('T')[0];
const [time, meridian] = booking.session_end_time.split(' '); // e.g., "2:00", "PM"
let [hours, minutes] = time.split(':').map(Number);

if (meridian === 'PM' && hours < 12) hours += 12;
if (meridian === 'AM' && hours === 12) hours = 0;

const sessionEndDateTime = new Date(booking.session_start_date);
sessionEndDateTime.setHours(hours, minutes, 0, 0);

  // Update payment fields
  booking.payment_method = method;
  booking.payment_status = 'paid';
  booking.status = 'confirmed';
  booking.session_end_datetime = sessionEndDateTime;

  await booking.save();
  console.log('💾 Booking updated and saved with confirmed status and paid payment_status');

  // Fetch caregiver and parent data
  const caregiver = await CareGiver.findById(booking.caregiver_id);
  const parent = await Parent.findById(booking.parent_id);

  if (!caregiver || !parent) {
    console.error('❌ Caregiver or Parent not found');
    throw new Error('Caregiver or Parent not found');
  }
  console.log('👤 Caregiver:', caregiver.first_name, '| 👪 Parent:', parent.firstName);

  const sessionDate = booking.session_start_date?.toISOString().split('T')[0];
  const sessionTime = `${booking.session_start_time} - ${booking.session_end_time}`;
  console.log('📅 Session info:', { sessionDate, sessionTime });

  // 📱 Send FCM Notifications
console.log('🔔 Sending FCM notifications...');

// ✅ Notify Parent
await NotificationService.sendTypedNotification({
  user_id: parent._id.toString(),
  user_type: 'Parent',
  title: '✅ تم تأكيد الحجز',
  message: `الجليسة ${caregiver.first_name} أكدت جلستك. يمكنك الآن التواصل أو الاستعداد للجلسة.`,
  fcm_token: parent.fcm_token,
  type: 'booking_confirmed',
  data: {
    booking_id: booking._id.toString(),
    status: 'confirmed',
  },
});

// ✅ Notify Caregiver
await NotificationService.sendTypedNotification({
  user_id: caregiver._id.toString(),
  user_type: 'CareGiver',
  title: '💰 تم تأكيد الحجز والدفع',
  message: `ولي الأمر ${parent.firstName} أكد الجلسة وتم الدفع.`,
  fcm_token: caregiver.fcm_token,
  type: 'booking_confirmed',
  data: {
    booking_id: booking._id.toString(),
    status: 'confirmed',
  },
});
  console.log('✅ FCM notifications sent');

  // 📡 Real-time updates via Socket.IO
  console.log('📡 Emitting real-time socket events...');
  io.to(parent._id.toString()).emit('booking_status_updated', {
    bookingId: booking._id.toString(),
    newStatus: 'confirmed',
  });

  io.to(caregiver._id.toString()).emit('booking_status_updated', {
    bookingId: booking._id.toString(),
    newStatus: 'confirmed',
  });
  console.log('✅ Socket events emitted');

  // 📧 Send Confirmation Emails
  const {
    getParentBookingConfirmedEmail,
    getCaregiverBookingConfirmedEmail,
  } = require('../../../utils/emailTemplates/bookingConfirmedTemplates');

  console.log('📧 Sending confirmation emails...');
  await sendEmail({
    to: parent.email,
    subject: '✅ تم تأكيد حجز جلستك',
    html: getParentBookingConfirmedEmail(sessionDate, sessionTime, caregiver.first_name),
  });

  await sendEmail({
    to: caregiver.email,
    subject: '💰 تم تأكيد الجلسة من قبل ولي الأمر',
    html: getCaregiverBookingConfirmedEmail(sessionDate, sessionTime, parent.firstName),
  });
  console.log('✅ Emails sent');

  return booking;
}

 static async createFallbackBooking(originalBookingId, newCaregiverId) {
    const original = await Booking.findById(originalBookingId);
    if (!original) throw new Error('Original booking not found');

    const fallbackBooking = await Booking.create({
      parent_id: original.parent_id,
      caregiver_id: newCaregiverId,
      service_type: original.service_type,
      session_address_type: original.session_address_type,
      city: original.city,
      neighborhood: original.neighborhood,
      street: original.street,
      building: original.building,
      session_start_date: original.session_start_date,
      session_end_date: original.session_end_date,
      session_start_time: original.session_start_time,
      session_end_time: original.session_end_time,
      session_days: original.session_days,
      children_ages: original.children_ages,
      has_medical_condition: original.has_medical_condition,
      medical_condition_details: original.medical_condition_details,
      takes_medicine: original.takes_medicine,
      medicine_details: original.medicine_details,
      additional_notes: original.additional_notes,
      rate_min: original.rate_min,
      rate_max: original.rate_max,
      additional_requirements: original.additional_requirements,
      consultation_topic: original.consultation_topic,
      special_needs_support: original.special_needs_support,
      preferred_contact_method: original.preferred_contact_method,
      session_duration_minutes: original.session_duration_minutes,
      status: 'accepted',
      is_fallback: true,
      original_booking_id: original._id
    });

    return fallbackBooking;
  }
}

module.exports = BabysitterBookingHandler;
