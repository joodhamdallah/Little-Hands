const CareGiver = require('../models/CareGiver');

async function updateCaregiverSubscription(userId, planType) {
  return await CareGiver.findByIdAndUpdate(userId, {
    subscription_status: 'paid',
    subscription_type: planType,
  });
}

module.exports = { updateCaregiverSubscription };
