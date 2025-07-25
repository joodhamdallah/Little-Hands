const mongoose = require('mongoose');

const babySitterSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'CareGiver',
    required: true,
    unique: true,
  },
  age_experience: [String], // multiple choices
  years_experience: {
    type: Number,
    required: true,
  },
  training_certification: [String], // array of strings like ["First Aid", "CPR"]
  skills_and_services: [String], // like ["Meal prep", "Toilet training"]
  bio: {
    type: String,
    required: true,
    minlength: 150,
  },
  rate_per_hour: {
    min: Number,
    max: Number,
  },
  number_of_children: Number,
  is_smoker: Boolean,
city: {
  type: String,
  required: true,
},
location: {
  type: {
    type: String,
    enum: ['Point'],
    default: 'Point',
  },
  coordinates: {
    type: [Number], // [longitude, latitude]
    required: true,
  }
},
  average_rating: {
    type: Number,
    default: null,
  },
  ratings_count: {
    type: Number,
    default: 0,
  }
}, {
  timestamps: true
});
babySitterSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('BabySitter', babySitterSchema);
