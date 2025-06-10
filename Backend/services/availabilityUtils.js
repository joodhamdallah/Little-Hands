const Booking = require('../models/Booking');
const WeeklyWorkPreference = require('../models/WeeklyWorkPreference');
const SpecificDatePreference = require('../models/SpecificDatePreference');

const moment = require('moment'); // already installed in most setups
require('moment/locale/ar'); // for Arabic day names

async function isCaregiverAvailable(userId, date, startTime, endTime) {
  console.log('📥 Checking availability for caregiver:', userId);
  console.log('📆 Date:', date);
  console.log('🕒 Requested Time:', startTime, '-', endTime);

  const weekly = await WeeklyWorkPreference.findOne({ caregiver_id: userId });
  const specific = await SpecificDatePreference.findOne({ caregiver_id: userId, date });

  console.log('📘 Weekly prefs:', weekly ? 'Found' : 'Not found');
  console.log('📗 Specific override:', specific ? 'Found' : 'Not found');

  // 1. Check if date is disabled
  const isDayDisabled = specific && specific.disabled === true;
  if (isDayDisabled) {
    console.log('🚫 Day is disabled in specific preferences');
    return false;
  }

  // 2. Get Arabic day name from date
  const dayName = moment(date).locale('ar').format('dddd');
  console.log('🗓 Arabic Day:', dayName);

  const dayPref = weekly?.preferences.find(p => p.day === dayName);

  if (!dayPref) {
    console.log('❌ No working preference found for this day');
    return false;
  }

  const preferredStart = specific?.start_time || dayPref.start_time;
  const preferredEnd = specific?.end_time || dayPref.end_time;

  console.log('🟢 Preferred working hours:', preferredStart, '-', preferredEnd);

  if (!preferredStart || !preferredEnd) {
    console.log('❌ No working hours defined — not available');
    return false;
  }

  // TODO: Add time comparison logic here
  return true;
}

module.exports = { isCaregiverAvailable };
