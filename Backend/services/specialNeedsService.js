const SpecialNeeds = require("../models/SpecialNeeds");

class SpecialNeedsService {
  static async saveProfile(userId, data) {
    const exists = await SpecialNeeds.findOne({ user_id: userId });
    if (exists) throw new Error("Profile already exists");

    const newProfile = new SpecialNeeds({
      user_id: userId,
      ...data
    });

    await newProfile.save();
    return newProfile;
  }

  static async getProfile(userId) {
    return await SpecialNeeds.findOne({ user_id: userId });
  }
}

module.exports = SpecialNeedsService;
