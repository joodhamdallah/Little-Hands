const WorkScheduleService = require('../services/workScheduleService');

exports.createWorkSchedule = async (req, res) => {
  try {
    const caregiverId = req.user._id; // ✅ مأخوذ من التوكن
    const { day, start_time, end_time } = req.body;

    if (!day || !start_time || !end_time) {
      return res.status(400).json({ status: false, message: "كل الحقول مطلوبة" });
    }

    const workSchedule = await WorkScheduleService.createSchedule(caregiverId, { day, start_time, end_time });

    res.status(201).json({
      status: true,
      message: "تم إنشاء الموعد بنجاح",
      data: workSchedule,
    });
  } catch (error) {
    console.error("❌ Error creating schedule:", error.message);
    res.status(500).json({ status: false, message: "حدث خطأ داخلي" });
  }
};

// 📥 جلب كل الجداول لهذا الكارجيڤر
exports.getWorkSchedules = async (req, res) => {
  try {
    const caregiverId = req.user._id;

    const schedules = await WorkScheduleService.getSchedules(caregiverId);

    res.status(200).json({
      status: true,
      schedules,
    });
  } catch (error) {
    console.error("❌ Error fetching schedules:", error.message);
    res.status(500).json({ status: false, message: "حدث خطأ داخلي" });
  }
};

exports.deleteWorkSchedule = async (req, res) => {
  try {
    const caregiverId = req.user._id;
    const { id } = req.params;

    const deleted = await WorkScheduleService.deleteSchedule(id , caregiverId );

    if (!deleted) {
      return res.status(404).json({ status: false, message: "لم يتم العثور على الجدول" });
    }

    res.status(200).json({
      status: true,
      message: "تم حذف الجدول بنجاح",
    });
  } catch (error) {
    console.error("❌ Error deleting schedule:", error.message);
    res.status(500).json({ status: false, message: "حدث خطأ داخلي" });
  }
};
