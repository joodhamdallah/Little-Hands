const CareGiver = require('../models/CareGiver');
const BabySitter = require('../models/BabySitter');
const SpecificDatePreference = require('../models/SpecificDatePreference');
const { isCaregiverAvailable } = require('./availabilityUtils');
const FallbackResponse = require('../models/FallbackResponse');
const Booking = require('../models/Booking');
const FallbackOffer = require('../models/FallbackOffer');
const NotificationService = require('./notificationService');
const Parent = require('../models/Parent'); // ✅ make sure this is required at the top

const FallbackService = {
  async broadcastFallbackOffer(booking, io) {
    const { session_start_date, session_start_time, session_end_time, city, caregiver_id, parent_id } = booking;

    const babysitters = await BabySitter.find({ city }).populate('user_id');

    const alternatives = [];

 for (const sitter of babysitters) {
  try {
    console.log('👀 Checking sitter:', sitter._id);

    const userId = sitter.user_id?._id?.toString();
    if (!userId) {
      console.log('⚠️ Skipping sitter with missing user_id');
      continue;
    }

    console.log('👤 Found userId:', userId);

    if (userId === caregiver_id.toString()) {
      console.log('⏩ Skipping original caregiver');
      continue;
    }

    const isAvailable = await isCaregiverAvailable(
      userId,
      session_start_date,
      session_start_time,
      session_end_time
    );

    console.log(`📅 Availability for ${userId}:`, isAvailable);

    if (!isAvailable) {
      console.log('⛔ Caregiver not available, skipping');
      continue;
    }

        // ✅ Store fallback offer
    await FallbackOffer.create({
      caregiver_id: userId,
      booking_id: booking._id,
    });
    
    console.log('✅ Adding as fallback candidate:', userId);

    alternatives.push({
      caregiver_id: userId,
      name: `${sitter.first_name} ${sitter.last_name}`,
      rate_min: sitter.rate_min,
      rate_max: sitter.rate_max,
      image: sitter.image,
    });

const socketId = global.onlineUsersMap[userId];
console.log('🔌 SocketId for fallback caregiver:', socketId);

// Always fetch caregiver data (for FCM token)
const caregiver = await CareGiver.findById(userId);
console.log('📱 Caregiver Token:', caregiver?.fcm_token);

const fallbackPayload = {
  booking_id: booking._id,
  session_date: session_start_date,
  start_time: session_start_time,
  end_time: session_end_time,
  city: booking.city,
  requirements: booking.additional_requirements,
  children_ages: booking.children_ages,
};

if (socketId) {
  io.to(socketId).emit('fallback_offer', fallbackPayload);
  console.log(`📤 Sent fallback_offer via socket to caregiver ${userId}`);
}

// Always send FCM, even if online
if (caregiver?.fcm_token) {
  await NotificationService.sendTypedNotification({
    user_id: userId,
    user_type: 'CareGiver',
    title: 'جلسة طارئة متاحة! 🔔',
    message: 'تم إلغاء جلسة مؤكدة ونبحث عن بديل. هل ترغب بتنفيذها؟',
    fcm_token: caregiver.fcm_token,
    type: 'fallback_offer',
    data: fallbackPayload,
  });

  console.log(`📲 FCM fallback_offer sent to caregiver ${userId}`);
} else {
  console.warn(`⚠️ No FCM token found for caregiver ${userId}`);
}


  const parentId = booking.parent_id.toString();
const parentSocket = global.onlineUsersMap?.[parentId];
const parent = await Parent.findById(parentId);

// Format session date
const formattedDate = new Date(session_start_date).toLocaleDateString('en-US', {
  weekday: 'long',
  year: 'numeric',
  month: 'long',
  day: 'numeric',
});

const emergencyMessage = {
  booking_id: booking._id.toString(),
  status: 'fallback_initiated',
  session_date: formattedDate,
};

if (parentSocket) {
  io.to(parentSocket).emit('emergency_fallback_started', emergencyMessage);
  console.log(`📡 Sent emergency_fallback_started to parent ${parentId}`);
}
let parentMessage = `تم إلغاء جلستك من قبل مقدم الرعاية بتاريخ ${formattedDate}.  سنرسل لك مقدمي رعاية بدلاء في أسرع وقت -في حال توفّرهم- إذا أردت اختيار بديل منهم`;

// 🔁 Add refund note if paid online
if (booking.payment_status === 'paid' && booking.payment_method === 'online') {
  parentMessage += '\n💳 نظرًا لأنك دفعت عبر البطاقة، سيتم إعادة المبلغ إلى بطاقتك تلقائيًا خلال أيام قليلة.';
}

if (parent?.fcm_token) {
  await NotificationService.sendTypedNotification({
    user_id: parentId,
    user_type: 'Parent',
    title: 'تم إلغاء الجلسة من قبل مقدم الرعاية 🚨',
    message: parentMessage,
    fcm_token: parent.fcm_token,
    type: 'emergency_fallback_started',
    data: emergencyMessage,
  });

  console.log(`📲 FCM fallback notification sent to parent ${parentId}`);
} else {
  console.warn(`⚠️ No FCM token found for parent ${parentId}`);
}

  } catch (err) {
    console.error('❌ Error while processing sitter:', sitter._id, err);
  }
}

    console.log(`✅ Sent fallback offers to ${alternatives.length} caregivers`);
  }
,
  
async respondToFallback(booking_id, caregiver_id, io) {
  // 🔁 Avoid duplicates
  const existing = await FallbackResponse.findOne({ booking_id, caregiver_id });
  if (existing) {
    console.log(`⚠️ Caregiver ${caregiver_id} already responded to fallback for booking ${booking_id}`);
    return { alreadyResponded: true };
  }

  // 💾 Save response
  await FallbackResponse.create({ booking_id, caregiver_id });
  console.log(`✅ Saved fallback response for caregiver ${caregiver_id} and booking ${booking_id}`);

  // 🔔 Notify parent
  const booking = await Booking.findById(booking_id);
  if (!booking) {
    console.log(`❌ Booking not found: ${booking_id}`);
    return { error: 'Booking not found' };
  }

  const parentId = booking.parent_id.toString();
  const parentSocket = global.onlineUsersMap?.[parentId];
const parent = await Parent.findById(parentId);

  console.log(`🧑‍🍼 Parent ID: ${parentId}`);
  console.log(`🔌 Parent Socket ID: ${parentSocket}`);

  // ✂️ inside FallbackService.respondToFallback AFTER socket branch
if ( parent?.fcm_token) {
  await NotificationService.sendTypedNotification({
    user_id: parentId,
    user_type: 'Parent',
    title: '🟢 مرشح جديد للجلسة البديلة',
    message: 'أحد مقدمي الرعاية وافق على تنفيذ الجلسة. يمكنك الآن استعراض الخيارات.',
    fcm_token: parent.fcm_token,
    type: 'fallback_candidates_ready',
    data: { booking_id: booking_id.toString() },
  });
  console.log(`📲 Sent FCM fallback_candidates_ready to offline parent ${parentId}`);
}

  if (parentSocket) {
    console.log(`📡 Sending fallback_candidates_ready to parent ${parentId}`);
    io.to(parentSocket).emit('fallback_candidates_ready', {
      booking_id,
      caregiver_id: caregiver_id.toString(),
    });
  } else {
    console.log(`🕸 Parent ${parentId} is not online. Could not send fallback_candidates_ready`);
  }

  return { alreadyResponded: false };
}
,

};

module.exports = FallbackService;
