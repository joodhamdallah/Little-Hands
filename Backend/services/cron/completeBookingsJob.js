// cron/completeBookingsJob.js
const cron = require('node-cron');
const Booking = require('../../models/Booking');

function scheduleCompleteBookingsJob() {
  // Runs every 15 minutes
  cron.schedule('*/10 * * * *', async () => {
    try {
      const now = new Date();

      const bookingsToComplete = await Booking.find({
        status: 'confirmed',
        session_end_datetime: { $lte: now }
      });

      for (const booking of bookingsToComplete) {
        booking.status = 'completed';
        await booking.save();
        console.log(`✅ Booking ${booking._id} marked as completed`);
      }

      console.log(`✅ Auto-completion job checked ${bookingsToComplete.length} bookings`);
    } catch (err) {
      console.error('❌ Cron job failed:', err);
    }
  });
}

module.exports = scheduleCompleteBookingsJob;
