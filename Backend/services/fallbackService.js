const CareGiver = require('../models/CareGiver');
const BabySitter = require('../models/BabySitter');
const WeeklyWorkPreference = require('../models/WeeklyWorkPreference');
const SpecificDatePreference = require('../models/SpecificDatePreference');
const { isCaregiverAvailable } = require('./availabilityUtils');
const FallbackResponse = require('../models/FallbackResponse');
const Booking = require('../models/Booking');

const FallbackService = {
  async broadcastFallbackOffer(booking, io) {
    const { session_start_date, session_start_time, session_end_time, city, caregiver_id } = booking;

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

    if (socketId) {
      io.to(socketId).emit('fallback_offer', {
        booking_id: booking._id,
        session_date: session_start_date,
        start_time: session_start_time,
        end_time: session_end_time,
        city: booking.city,
        requirements: booking.additional_requirements,
        children_ages: booking.children_ages,
      });

      console.log(`📤 Sent fallback_offer to caregiver ${userId}`);
    } else {
      console.log(`🕸 Caregiver ${userId} is not online`);
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

  console.log(`🧑‍🍼 Parent ID: ${parentId}`);
  console.log(`🔌 Parent Socket ID: ${parentSocket}`);

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
