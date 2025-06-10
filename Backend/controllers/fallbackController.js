
const FallbackService = require('../services/fallbackService');
const FallbackResponse = require('../models/FallbackResponse');
const CareGiver = require('../models/CareGiver');
const BabySitter = require('../models/BabySitter');

exports.respondToFallback = async (req, res) => {
  try {
    const caregiver_id = req.user._id;
    const { booking_id } = req.body;

    const result = await FallbackService.respondToFallback(booking_id, caregiver_id, req.app.get('io'));

    if (result.alreadyResponded) {
      return res.status(200).json({ message: 'Already responded.' });
    }

    return res.status(200).json({ message: 'Response recorded' });
  } catch (err) {
    console.error('❌ Error in respondToFallback:', err);
    res.status(500).json({ error: 'Failed to respond' });
  }
};
exports.getFallbackCandidates = async (req, res) => {
  try {
    const booking_id = req.params.bookingId;

    const responses = await FallbackResponse.find({ booking_id, accepted: true });

    const candidates = await Promise.all(
      responses.map(async (r) => {
        const sitter = await BabySitter.findOne({ user_id: r.caregiver_id }).populate("user_id");

        if (!sitter || !sitter.user_id) return null;

        const caregiver = sitter.user_id;

        const formattedName = `${caregiver.first_name} ${caregiver.last_name}`;
        const sitterSkills = sitter.skills_and_services?.slice(0, 3) ?? [];
        const shortBio = sitter.bio?.substring(0, 100) + '...';

        let priceText = "غير محدد";
        if (sitter.fixed_rate_per_hour) {
          priceText = `${sitter.fixed_rate_per_hour} شيكل بالساعة`;
        } else if (sitter.rate_per_hour?.min && sitter.rate_per_hour?.max) {
          priceText = `من ${sitter.rate_per_hour.min} إلى ${sitter.rate_per_hour.max} شيكل بالساعة`;
        }

        const location = sitter.location?.coordinates
          ? {
              lat: sitter.location.coordinates[1],
              lng: sitter.location.coordinates[0],
            }
          : null;

        return {
          id: sitter._id,
          user_id: caregiver._id,
          fullName: formattedName,
          image: caregiver.image || null,
          city: sitter.city,
          yearsExperience: sitter.years_experience,
          skills: sitterSkills,
          shortBio,
          rateText: priceText,
          location,
          average_rating: sitter.average_rating ?? null,
          ratings_count: sitter.ratings_count ?? 0,
        };
      })
    );

    const sorted = candidates.filter(Boolean).sort((a, b) => (b.average_rating ?? 0) - (a.average_rating ?? 0));

    res.json({ candidates: sorted });
  } catch (error) {
    console.error("❌ Error in getFallbackCandidates:", error);
    res.status(500).json({ message: "Server error" });
  }
};
