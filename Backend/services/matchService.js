const BabySitter = require('../models/BabySitter');
const CareGiver = require('../models/CareGiver');

// ✅ Helper to calculate distance in KM
function getDistanceInKm(lat1, lon1, lat2, lon2) {
  const R = 6371; // Radius of Earth in km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(deg2rad(lat1)) *
      Math.cos(deg2rad(lat2)) *
      Math.sin(dLon / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}
function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

class MatchService {
  static async matchBabysitters({ city, location, childrenAges, rateMin, rateMax, additionalRequirements, isNegotiable }) {
    try {
      const filter = {
        city,
        age_experience: { $in: childrenAges || [] },
      };

      if (!isNegotiable) {
        filter.$or = [
          {
            $and: [
              { 'rate_per_hour.min': { $lte: rateMax } },
              { 'rate_per_hour.max': { $gte: rateMin } },
            ]
          },
          {
            $expr: {
              $and: [
                { $eq: ['$rate_per_hour.min', '$rate_per_hour.max'] },
                { $lte: ['$rate_per_hour.min', rateMax] },
                { $gte: ['$rate_per_hour.min', rateMin] }
              ]
            }
          }
        ];
      }

      const babysitters = await BabySitter.find(filter).populate({
        path: 'user_id',
        match: { subscription_status: 'paid', role: 'babysitter' },
        select: 'first_name last_name image subscription_status'
      });

      const filteredSitters = babysitters.filter(sitter => sitter.user_id);

      const maxScore = (additionalRequirements.length * 5) + (childrenAges.length * 4) + 3 + 3; // +3 for distance

      const scoredSitters = filteredSitters.map(sitter => {
        let score = 0;
        const sitterSkills = sitter.skills_and_services || [];
        const sitterAges = sitter.age_experience || [];

        // Skills score
        const matchedSkillsCount = additionalRequirements.filter(req => sitterSkills.includes(req)).length;
        score += matchedSkillsCount * 5;

        // ✅ Rate matching (only if not negotiable)
        if (!isNegotiable) {
          const sitterMin = sitter.rate_per_hour.min;
          const sitterMax = sitter.rate_per_hour.max;
          if (
            (sitterMin === sitterMax && sitterMin >= rateMin && sitterMin <= rateMax) ||
            (sitterMin <= rateMax && sitterMax >= rateMin)
          ) {
            score += 3;
          }
        }

        // ✅ Children ages matching
        const matchedAgesCount = childrenAges.filter(age => sitterAges.includes(age)).length;
        score += matchedAgesCount * 4;

        // Distance score
        let distanceInKm = null;
        if (location && sitter.location?.coordinates) {
          const [sitterLng, sitterLat] = sitter.location.coordinates;
          const parentLat = location.lat;
          const parentLng = location.lng;
          distanceInKm = getDistanceInKm(parentLat, parentLng, sitterLat, sitterLng);

          // 3 points for 0km, 0 for 10km+ (linear decay)
          const distanceScore = Math.max(0, 3 - (distanceInKm / 10) * 3);
          score += distanceScore;
        }

        const priceText = sitter.rate_per_hour.min === sitter.rate_per_hour.max
          ? `₪ ${sitter.rate_per_hour.min} / ساعة`
          : `₪ ${sitter.rate_per_hour.min} - ₪ ${sitter.rate_per_hour.max} / ساعة`;

        const matchingPercentage = maxScore > 0 ? ((score / maxScore) * 100).toFixed(0) : 0;
        const firstName = sitter.user_id.first_name || "";
        const lastName = sitter.user_id.last_name || "";
        const formattedName = `${firstName} ${lastName.charAt(0)}.`;
        const shortBio = sitter.bio ? sitter.bio.split(' ').slice(0, 20).join(' ') + "..." : "";
      
        console.log(`🧡 Babysitter: ${formattedName} | Score: ${score} / ${maxScore} | Matching: ${matchingPercentage}%`);

        return {
          id: sitter._id,
           user_id: sitter.user_id._id, 
          fullName: formattedName,
          image: sitter.user_id.image || null,
          city: sitter.city,
          yearsExperience: sitter.years_experience,
          skills: sitterSkills,
          shortBio,
          rateText: priceText,
          score,
          matchingPercentage,
          
          distanceInKm: distanceInKm ? distanceInKm.toFixed(1) : null,
           location: sitter.location?.coordinates
    ? {
        lat: sitter.location.coordinates[1],
        lng: sitter.location.coordinates[0],
      }
    : null,
    average_rating: sitter.average_rating ?? null,      // ⭐ Include this
    ratings_count: sitter?.ratings_count ?? 0,           // ⭐ Optionally includ
        };
      });

      scoredSitters.sort((a, b) => b.score - a.score);
      return scoredSitters;
    } catch (error) {
      throw error;
    }
  }

  static async getBabysitterProfileById(babysitterId) {
    try {
    const babysitter = await BabySitter.findOne({ user_id: babysitterId }).populate({
        path: 'user_id',
        select: 'first_name last_name image'
      });

    if (!babysitter || !babysitter.user_id) {
      return null;
    }

    let priceText = "";
    if (babysitter.rate_per_hour) {
      const min = babysitter.rate_per_hour.min;
      const max = babysitter.rate_per_hour.max;
      priceText = (min === max)
        ? `₪ ${min} / ساعة`
        : `₪ ${min} - ₪ ${max} / ساعة`;
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
        rateText: priceText,
         location: babysitter.location?.coordinates 
    ? { 
        lat: babysitter.location.coordinates[1], 
        lng: babysitter.location.coordinates[0] 
      }
    : null,
      };
    } catch (error) {
      throw error;
    }
  }
}

module.exports = MatchService;
