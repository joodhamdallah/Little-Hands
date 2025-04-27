const BabySitter = require('../models/BabySitter');
const CareGiver = require('../models/CareGiver');

class MatchService {
  static async matchBabysitters({ city, childrenAges, rateMin, rateMax, additionalRequirements }) {
    try {
      const babysitters = await BabySitter.find({
        city: city,
        age_experience: { $in: childrenAges },
        'rate_per_hour.min': { $lte: rateMax },
        'rate_per_hour.max': { $gte: rateMin }
      }).populate({
        path: 'user_id',
        match: { subscription_status: 'paid', role: 'babysitter' },
        select: 'first_name last_name image subscription_status'
      });

      const filteredSitters = babysitters.filter(sitter => sitter.user_id && sitter.city === city);

      // ✅ حساب الماكسيمم سكور
      const maxScore = (additionalRequirements.length * 5) + (childrenAges.length * 4) + 3;

      const scoredSitters = filteredSitters.map(sitter => {
        let score = 0;

        const sitterSkills = sitter.skills_and_services || [];
        const sitterAges = sitter.age_experience || [];

        // ✅ Skills matching
        const matchedSkillsCount = additionalRequirements.filter(req => sitterSkills.includes(req)).length;
        score += matchedSkillsCount * 5;

        // ✅ Rate matching
        const sitterMin = sitter.rate_per_hour.min;
        const sitterMax = sitter.rate_per_hour.max;
        if (sitterMin <= rateMax && sitterMax >= rateMin) {
          score += 3;
        }

        // ✅ Children ages matching
        const matchedAgesCount = childrenAges.filter(age => sitterAges.includes(age)).length;
        score += matchedAgesCount * 4;

        // ✅ نسبة التطابق
        const matchingPercentage = maxScore > 0 ? ((score / maxScore) * 100).toFixed(0) : 0;

        const firstName = sitter.user_id.first_name || "";
        const lastName = sitter.user_id.last_name || "";
        const formattedName = `${firstName} ${lastName.charAt(0)}.`;

        const shortBio = sitter.bio ? sitter.bio.split(' ').slice(0, 20).join(' ') + "..." : "";

        // ✅ نطبع كل وحدة
        console.log(`🧡 Babysitter: ${formattedName} | Score: ${score} / ${maxScore} | Matching: ${matchingPercentage}%`);

        return {
          id: sitter._id,
          fullName: formattedName,
          image: sitter.user_id.image || null,
          city: sitter.city,
          yearsExperience: sitter.years_experience,
          skills: sitterSkills,
          shortBio: shortBio,
          score: score,
          matchingPercentage: matchingPercentage
        };
      });

      // 🔥 ترتيب حسب الأعلى سكور
      scoredSitters.sort((a, b) => b.score - a.score);

      return scoredSitters;
    } catch (error) {
      throw error;
    }
  }

  static async getBabysitterProfileById(babysitterId) {
    try {
      const babysitter = await BabySitter.findById(babysitterId).populate({
        path: 'user_id',
        select: 'first_name last_name image'
      });

      if (!babysitter || !babysitter.user_id) {
        return null;
      }

      return {
        id: babysitter._id,
        first_name: babysitter.user_id.first_name,
        last_name: babysitter.user_id.last_name,
        image: babysitter.user_id.image,
        city: babysitter.city,
        years_experience: babysitter.years_experience,
        skills_and_services: babysitter.skills_and_services || [],
        training_certification: babysitter.training_certification || [],
        bio: babysitter.bio || '',
        is_smoker: babysitter.is_smoker || false,
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = MatchService;
