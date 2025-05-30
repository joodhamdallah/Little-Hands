const { createCheckoutSession } = require('../services/stripeService');
const { createBookingCheckoutSession } = require('../services/stripeService');

exports.handleCheckoutSession = async (req, res) => {
  try {
    const userId = req.user?._id;
    const { plan } = req.body;

    if (!userId || !plan) {
      return res.status(400).json({
        status: false,
        message: 'معلومات غير مكتملة: يجب إرسال userId و plan.',
      });
    }

    const session = await createCheckoutSession(userId, plan);

    res.status(200).json({
      status: true,
      message: 'تم إنشاء جلسة الدفع بنجاح.',
      url: session.url, // سيتم توجيه المستخدم لهذا الرابط
    });
  } catch (error) {
    console.error('❌ Stripe Checkout Error:', error.message);
    res.status(500).json({
      status: false,
      message: 'حدث خطأ أثناء إنشاء جلسة الدفع.',
      error: error.message,
    });
  }
};

// backend controller
const Booking = require('../models/Booking');

exports.handleBookingCheckoutSession = async (req, res) => {
  try {
    const { booking_id } = req.body;

    if (!booking_id) {
      return res.status(400).json({ message: 'Missing booking ID' });
    }

    const booking = await Booking.findById(booking_id);
    if (!booking || !booking.price_details?.total) {
      return res.status(404).json({ message: 'Booking not found or price missing' });
    }

    const session = await createBookingCheckoutSession(booking_id, booking.price_details.total);

    res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('❌ Booking checkout error:', err.message);
    res.status(500).json({ error: 'Failed to create booking payment session' });
  }
};

