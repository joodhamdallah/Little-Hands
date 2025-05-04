const BookingServices = require('../services/bookingService');

exports.createBooking = async (req, res) => {
  try {
    const parentId = req.user._id; // مفترض انه parent مصادق عليه من middleware
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
