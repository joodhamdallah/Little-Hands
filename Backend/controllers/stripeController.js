const { createCheckoutSession } = require('../services/stripeService');

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
