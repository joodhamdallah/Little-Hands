
const WorkSchedule = require("../models/WorkSchedule"); 
const BabySitter = require("../models/BabySitter"); 
class WorkScheduleService {

    static async createSchedule(userId, scheduleData) {
    const babysitter = await BabySitter.findOne({ user_id: userId });
    if (!babysitter) {
      throw new Error("Babysitter profile not found");
    }

    const newSchedule = new WorkSchedule({
      caregiver_id: userId,  
      ...scheduleData
    });

    return await newSchedule.save();
  }

  static async getSchedules(userId) {  
    return await WorkSchedule.find({ caregiver_id: userId });
  }

  static async deleteSchedule(scheduleId, userId) {
    const schedule = await WorkSchedule.findById(scheduleId);
    
    if (!schedule) {
      throw new Error("Schedule not found");
    }
    
    if (schedule.caregiver_id.toString() !== userId.toString()) {
      throw new Error("Unauthorized to delete this schedule");
    }
  
    await WorkSchedule.findByIdAndDelete(scheduleId);
  
    return schedule;
  }

  static async updateSchedule(scheduleId, userId, updatedData) {
    const schedule = await WorkSchedule.findOneAndUpdate(
      { _id: scheduleId, user_id: userId },
      updatedData,
      { new: true }
    );

    if (!schedule) {
      throw new Error("Schedule not found or unauthorized");
    }

    return schedule;
  }
}

module.exports = WorkScheduleService;
