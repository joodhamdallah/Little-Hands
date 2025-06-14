const Booking = require('../../models/Booking');

exports.getParentBookings = async (req, res) => {
  const parentId = req.user._id;
  const bookings = await Booking.find({ parent_id: parentId })
    .populate('caregiver_id', 'first_name last_name image')
    .sort({ session_start_date: 1 });

  res.json({ status: true, data: bookings });
};

exports.getBookingsForCaregiver = async (req, res) => {
  const caregiverId = req.user._id;

  const bookings = await Booking.find({ caregiver_id: caregiverId,  status: { $in: ['accepted', 'confirmed','meeting_booked'] }
 })
    .populate('parent_id', 'firstName lastName email phone')  // ✅ populate parent info
    .sort({ createdAt: -1 });
  res.status(200).json({ status: true, data: bookings });
};

exports.getBookingsByCaregiverId = async (req, res) => {
  const caregiverId = req.params.id;
  const bookings = await Booking.find({ caregiver_id: caregiverId, status: { $in: ['accepted', 'confirmed','meeting_booked'] }});

  res.status(200).json({ status: true, data: bookings });
};
