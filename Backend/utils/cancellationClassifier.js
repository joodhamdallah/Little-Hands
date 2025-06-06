function classifyCancellationStats(stats) {
  const { total, pending = 0, accepted = 0, meeting_booked = 0, confirmed = 0 } = stats;

  if (total >= 6) return '⚠️ كثير الإلغاء';
  if (confirmed >= 4) return '🔴 غالبًا يُلغي بعد التأكيد';
  if (accepted >= 3) return '⚠️ يُلغي بعد القبول';
  if (pending >= 4) return '📌 يُلغي كثيرًا قبل الرد';
  if (meeting_booked >= 3) return '📌 يُلغي بعد حجز الاجتماعات';

  return null; // No label
}

function isLastMinuteCancellation(booking) {
  if (!booking.cancelled_at || !booking.session_start_date || !booking.session_start_time) return false;

  const [hourStr, minuteStr] = booking.session_start_time.split(':');
  let hour = parseInt(hourStr);
  let minute = parseInt(minuteStr);
  if (booking.session_start_time.toLowerCase().includes('pm') && hour < 12) hour += 12;
  if (booking.session_start_time.toLowerCase().includes('am') && hour === 12) hour = 0;

  const sessionDateTime = new Date(booking.session_start_date);
  sessionDateTime.setHours(hour, minute, 0, 0);

  const diffMs = sessionDateTime - new Date(booking.cancelled_at);
  const diffMinutes = diffMs / (1000 * 60);

  return diffMinutes <= 120; // 2 hours before session
}

function getLastMinuteLabel(booking) {
  return isLastMinuteCancellation(booking) ? '🔴 قد يُلغي في اللحظة الأخيرة' : null;
}
async function getCancellationLabelForCaregiver(caregiverId) {
  const statsDoc = await CancellationStats.findOne({ user_id: caregiverId, role: 'caregiver' });
  if (!statsDoc || !statsDoc.stats) return null;
  return classifyCancellationStats(statsDoc.stats);
}
module.exports = {
  classifyCancellationStats,
  isLastMinuteCancellation,
  getLastMinuteLabel,
    getCancellationLabelForCaregiver, // ✅ Add this

};
