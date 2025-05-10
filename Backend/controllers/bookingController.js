const Booking = require('../models/Booking');
const BookingServices = require('../services/bookingService');

exports.createBooking = async (req, res) => {
  try {
    const parentId = req.user._id;
    const bookingData = {
      ...req.body,
      parent_id: parentId
    };

    const newBooking = await BookingServices.createBooking(bookingData);
    
    res.status(201).json({
      status: true,
      message: 'تم إرسال طلب الحجز بنجاح.',
      data: newBooking
    });

  } catch (error) {
    console.error('❌ Error creating booking:', error);
    res.status(500).json({
      status: false,
      message: 'فشل في إنشاء الحجز.',
      error: error.message
    });
  }
};

exports.getBookingsForCaregiver = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const bookings = await Booking.find({ caregiver_id: caregiverId }).sort({ createdAt: -1 });
    
    res.status(200).json({
      status: true,
      data: bookings,
    });
  } catch (error) {
    console.error("❌ Error fetching caregiver bookings:", error.message);
    res.status(500).json({
      status: false,
      message: "حدث خطأ أثناء جلب الحجوزات",
    });
  }
};
