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
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة'
    ],
  },

  date: {
    type: Date,
    required: true
  },
  
  start_time: {
    type: String, // hh:mm format
    required: true,
  },
  end_time: {
    type: String, // hh:mm format
    required: true,
  },

  type: {
    type: String,
    enum: ['meeting', 'work'],
    required: true,
    default: 'meeting', 
  }
  


}, {
  timestamps: true
});

module.exports = mongoose.model('WorkSchedule', workScheduleSchema);
