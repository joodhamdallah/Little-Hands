const Expert = require("../models/Expert");

class ExpertService {
  static async saveProfile(userId, data) {
    const exists = await Expert.findOne({ user_id: userId });
    if (exists) throw new Error("Profile already exists");

    const expert = new Expert({ user_id: userId, ...data });
    await expert.save();
    return expert;
  }

  static async getProfile(userId) {
    return await Expert.findOne({ user_id: userId });
  }
}

module.exports = ExpertService;
