// services/feedbackService.js
const Feedback = require('../models/Feedback');
const Parent = require('../models/Parent');
const BabySitter = require('../models/BabySitter');

function calculateOverallRating(ratings) {
  const values = Object.values(ratings)
    .filter(v => typeof v === 'number' && v > 0); // ✅ تجاهل القيم 0

  if (values.length === 0) return null;

  const total = values.reduce((sum, v) => sum + v, 0);
  const average = total / values.length;
  return parseFloat(average.toFixed(1));
}


module.exports = {
  // ✅ 1. Submit new feedback
async submitFeedback(req) {  console.log("📥 Feedback submission initiated...");

  const {
    booking_id,
    to_user_id,
    to_role,
    from_role,
    ratings,
    comments,
    type,
  } = req.body;

  console.log("📥 Feedback submission initiated...");
  console.log("🧾 Booking ID:", booking_id);
  console.log("👤 From (user_id):", req.user._id);
  console.log("👤 To (user_id):", to_user_id);
  console.log("📌 From Role:", from_role, "→ To Role:", to_role);
  console.log("📊 Ratings:", ratings);
  console.log("🗣️ Comments:", comments);
  console.log("📁 Type:", type);

  const overall_rating =
    type === 'completed' && ratings
      ? calculateOverallRating(ratings)
      : null;

  console.log("⭐ Calculated overall rating:", overall_rating);

  const feedback = new Feedback({
    booking_id,
    from_user_id: req.user._id,
    to_user_id,
    from_role,
    to_role,
    ratings,
    comments,
    overall_rating,
    type,
  });

  await feedback.save();
  console.log("✅ Feedback saved to DB:", feedback._id);

  // ✅ Recalculate average rating and update the corresponding model
  if (type === 'completed' && overall_rating !== null) {
    console.log("🔁 Recalculating average rating for:", to_role);

    const allFeedbacks = await Feedback.find({
      to_user_id,
      to_role,
      type: 'completed',
      overall_rating: { $ne: null },
    });

    console.log(`📦 Found ${allFeedbacks.length} relevant feedbacks.`);

    const ratings = allFeedbacks.map(f => f.overall_rating);
    const sum = ratings.reduce((acc, val) => acc + val, 0);
    const avg = ratings.length > 0 ? parseFloat((sum / ratings.length).toFixed(1)) : null;

    console.log("📐 New average:", avg);

    if (to_role === 'caregiver') {
      const update = await BabySitter.findOneAndUpdate(
        { user_id: to_user_id },
        {
          average_rating: avg,
          ratings_count: ratings.length,
        },
        { new: true }
      );
      console.log("🍼 Updated babysitter average:", update);
    } else if (to_role === 'parent') {
      const update = await Parent.findByIdAndUpdate(
        to_user_id,
        {
          avg_rating: avg,
          num_reviews: ratings.length,
        },
        { new: true }
      );
      console.log("👨‍👩‍👧 Updated parent average:", update);
    }
  }

  return {
    status: 200,
    data: { message: 'Feedback submitted successfully', feedback },
  };
}
,

  // ✅ 2. Get all feedback *received* by caregiver (admin/internal use)
  async getForCaregiver(caregiverId) {
     const feedbacks = await Feedback.find({
    to_user_id: caregiverId,
    to_role: 'caregiver',
    type: { $in: ['completed'] },
    from_role: 'parent'
  })
    .populate({
      path: 'from_user_id',
      model: 'Parent', // ✅ make sure this matches your model name
      select: 'firstName lastName ',
    })
    .sort({ overall_rating: -1 });

  return feedbacks;
  },

  // ✅ 3. Get all feedback *received* by parent (admin/internal use)
  async getForParent(parentId) {
    return await Feedback.find({ to_user_id: parentId, to_role: 'parent' })
      .sort({ created_at: -1 });
  },

  // ✅ 4. Public feedback for caregiver (seen by parents before booking)
 async getPublicFeedbackForCaregiver(caregiverId) {
  console.log('📥 Getting public feedback for caregiver:', caregiverId);

  const feedbacks = await Feedback.find({
    to_user_id: caregiverId,
    to_role: 'caregiver',
type: { $in: ['completed', 'cancelled'] },
    from_role: 'parent' // ✅ Only populate if from_role is parent
  })
    .populate({
      path: 'from_user_id',
      model: 'Parent', // ✅ Static model name
      select: 'firstName lastName image',
    })
    .sort({ overall_rating: -1 });

  console.log(`✅ Fetched ${feedbacks.length} feedback(s). Sample:`, feedbacks[0]);

  return feedbacks;
}
,
async getPublicFeedbackForParent(parentId) {
  return await Feedback.find({
    to_user_id: parentId,
    to_role: 'parent',
    type: 'completed',
  })
    .populate({
      path: 'to_user_id',
      model: 'Parent',
      select: 'firstName lastName'
    })
    .populate({
      path: 'from_user_id',
      model: 'CareGiver',
      select: 'first_name last_name image'
    })
    .sort({ overall_rating: -1 });
}


,
  // ✅ 6. Check if current user already submitted feedback for a booking
  async checkFeedbackForBooking(req) {
    const existing = await Feedback.findOne({
      booking_id: req.params.bookingId,
      from_user_id: req.user._id,
    });

    return { exists: !!existing };
  },

  // ✅ 7. Get all feedbacks submitted by current user
  async getMyFeedbacks(userId) {
    return await Feedback.find({ from_user_id: userId })
      .sort({ created_at: -1 })
     .populate([
  {
    path: 'to_user_id',
    model: 'CareGiver',
    select: 'first_name last_name role',
  },
  {
    path: 'booking_id',
    model: 'Booking',
    select: 'session_start_date',
  }
]);
  },

  // ✅ 8. Update feedback (optional)
  async updateFeedback(id, req) {
    const updates = req.body;

    const feedback = await Feedback.findOneAndUpdate(
      { _id: id, from_user_id: req.user._id },
      updates,
      { new: true }
    );

    if (!feedback) {
      return {
        status: 404,
        data: { message: 'Feedback not found or not authorized' },
      };
    }

    return {
      status: 200,
      data: { message: 'Feedback updated', feedback },
    };
  },

  async  getRatedBookingIds(userId) {
  const feedbacks = await Feedback.find({
    from_user_id: userId,
    // from_role: 'parent',
  }).select('booking_id');

  return feedbacks.map(fb => fb.booking_id.toString());
}
// ,
//   async  getRatedBookingIds(userId) {
//   const feedbacks = await Feedback.find({
//     from_user_id: userId,
//     from_role: 'caregiver',
//   }).select('booking_id');

//   return feedbacks.map(fb => fb.booking_id.toString());
// }
};
