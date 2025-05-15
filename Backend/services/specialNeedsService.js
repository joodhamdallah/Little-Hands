const SpecialNeeds = require("../models/SpecialNeeds");

class SpecialNeedsService {
  static async saveProfile(userId, data) {
    const exists = await SpecialNeeds.findOne({ user_id: userId });
    if (exists) throw new Error("Profile already exists");


    if (data.rate && data.rate_type) {
      data.rate = {
        amount: parseFloat(data.rate),
        type: data.rate_type
      };
      delete data.rate_type;
    }

    if (data.training_certifications) {
      data.trainings = data.training_certifications;
      delete data.training_certifications;
    }

    if (data.can_accompany_to_school !== undefined) {
      data.can_accompany_in_school = data.can_accompany_to_school;
      delete data.can_accompany_to_school;
    }

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
