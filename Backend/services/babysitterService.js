// services/babysitterService.js

const BabySitter = require('../models/BabySitter');

/**
 * Create and save babysitter details after caregiver registration.
 * @param {Object} data - Data from the frontend (after caregiver registers and selects category).
 * @returns {Promise<BabySitter>} - Saved babysitter document.
 */
const createSitterDetails = async (data) => {
const { user_id, location, ...rest } = data;

  // Check if babysitter details already exist for this user
  const existing = await BabySitter.findOne({ user_id });
  if (existing) {
    throw new Error('Details already submitted for this caregiver.');
  }

  const geoLocation = {
  type: 'Point',
  coordinates: [location.lng, location.lat] // GeoJSON expects [lng, lat]
};

const sitter = new BabySitter({
  user_id,
  location: geoLocation,
  ...rest
});
  return await sitter.save();
};

/**
 * Optionally: Get babysitter profile by caregiver ID
 */
const getSitterByUserId = async (user_id) => {
  return await BabySitter.findOne({ user_id });
};

module.exports = {
  createSitterDetails,
  getSitterByUserId
};
