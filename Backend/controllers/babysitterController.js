const babysitterService = require('../services/babysitterService');

exports.saveBabySitterDetails = async (req, res) => {
  try {
    const data = req.body;
    
    // جلب user_id من التوكن أو من البيانات القادمة
    const userId = req.user?.id || data.user_id;
    if (!userId) {
      return res.status(400).json({
        status: false,
        message: 'معرّف المستخدم غير موجود.',
      });
    }

    // دمج البيانات مع user_id
    const savedData = await babysitterService.createSitterDetails({
      ...data,
      user_id: userId,
    });

    res.status(201).json({
      status: true,
      message: 'تم حفظ بيانات جليسة الأطفال بنجاح.',
      data: savedData,
    });

  } catch (error) {
    console.error('❌ Error in controller:', error.message, '\n', error.stack);
    res.status(500).json({
      status: false,
      message: 'حدث خطأ أثناء حفظ البيانات',
      error: error.message, // اختياري لمساعدتك أثناء التطوير
    });
  }
};
