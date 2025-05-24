// bookingController.js
const BookingServices = require('../services/booking/bookingService');

exports.getBookingsForCaregiver = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const bookings = await Booking.find({ caregiver_id: caregiverId }).sort({ createdAt: -1 });
    res.status(200).json({ status: true, data: bookings });
  } catch (error) {
    res.status(500).json({ status: false, message: 'حدث خطأ أثناء جلب الحجوزات' });
  }
};

exports.getBookingsByCaregiverId = async (req, res) => {
  try {
    const caregiverId = req.params.id;
    const bookings = await Booking.find({ caregiver_id: caregiverId, status: 'confirmed' });
    res.status(200).json({ status: true, data: bookings });
  } catch (error) {
    res.status(500).json({ status: false, message: 'خطأ في جلب الحجوزات' });
  }
};

exports.getParentBookings = async (req, res) => {
  try {
    const parentId = req.user._id;
    const bookings = await Booking.find({ parent_id: parentId })
      .populate('caregiver_id', 'first_name last_name profile_image')
      .sort({ session_start_date: 1 });
    res.status(200).json({ status: true, data: bookings });
  } catch (error) {
    res.status(500).json({ status: false, message: 'خطأ في جلب الحجوزات' });
  }
};

exports.createBooking = async (req, res) => {
  try {
    const parentId = req.user._id;
    const bookingData = { ...req.body, parent_id: parentId };
    const io = req.app.get('io');
    const newBooking = await BookingServices.createBooking(bookingData, io);
    res.status(201).json({ status: true, message: 'تم إرسال طلب الحجز بنجاح.', data: newBooking });
  } catch (error) {
    res.status(500).json({ status: false, message: 'فشل في إنشاء الحجز.', error: error.message });
  }
};

exports.confirmBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const io = req.app.get('io');
    const updated = await BookingServices.confirmBooking(bookingId, io);
    res.status(200).json({ message: 'تم تأكيد الحجز', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في تأكيد الحجز' });
  }
};

exports.rejectBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const updated = await BookingServices.rejectBooking(bookingId);
    res.status(200).json({ message: 'تم رفض الحجز', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في رفض الحجز' });
  }
};

exports.acceptBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const io = req.app.get('io');
    const updated = await BookingServices.acceptBooking(bookingId, io);
    res.status(200).json({ message: 'تم قبول الحجز', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في قبول الحجز' });
  }
};

exports.bookMeeting = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const meetingData = req.body;
    const updated = await BookingServices.bookMeeting(bookingId, meetingData);
    res.status(200).json({ message: 'تم حجز الاجتماع بنجاح', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في حجز الاجتماع' });
  }
};

exports.cancelBooking = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const cancelledBy = req.body.cancelledBy;
    const updated = await BookingServices.cancelBooking(bookingId, cancelledBy);
    res.status(200).json({ message: 'تم إلغاء الحجز', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في إلغاء الحجز' });
  }
};

exports.markCompleted = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const updated = await BookingServices.markCompleted(bookingId);
    res.status(200).json({ message: 'تم إنهاء الجلسة', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في إنهاء الجلسة' });
  }
};

exports.markAsPaid = async (req, res) => {
  try {
    const bookingId = req.params.id;
    const updated = await BookingServices.markAsPaid(bookingId);
    res.status(200).json({ message: 'تم تسجيل الدفع بنجاح', data: updated });
  } catch (error) {
    res.status(500).json({ message: 'خطأ في تسجيل الدفع' });
  }
};
