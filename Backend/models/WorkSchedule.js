const mongoose = require('mongoose');

const workScheduleSchema = new mongoose.Schema({
  caregiver_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CareGiver',
    required: true,
  },
  day: {
    type: String,
    required: true,
    enum: [
      'السبت',
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ],
  },
  start_time: {
    type: String, // hh:mm format
    required: true,
  },
  end_time: {
    type: String, // hh:mm format
    required: true,
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('WorkSchedule', workScheduleSchema);
