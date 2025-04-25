const CareGiver = require('../models/CareGiver');

exports.handleStripeWebhook = async (req, res) => {
  try {
    const rawBody = req.body.toString('utf8');
    const event = JSON.parse(rawBody);

    console.log('📦 Received event:', event.type);

    if (event.type !== 'checkout.session.completed') {
      return res.status(200).json({ message: 'Ignored other event type' });
    }

    const session = event.data.object;
    const userId = session.metadata?.user_id;
    const plan = session.metadata?.plan_type;

    if (!userId || !plan) {
      console.log('❌ Missing metadata');
      return res.status(400).json({ message: 'Missing metadata' });
    }

    const updated = await CareGiver.findByIdAndUpdate(
      userId,
      {
        subscription_status: 'paid',
        subscription_type: plan,
      },
      { new: true }
    );

    if (!updated) {
      console.log('❌ Caregiver not found');
      return res.status(404).json({ message: 'Caregiver not found' });
    }

    console.log(`✅ Updated caregiver ${userId} with plan ${plan}`);
    res.status(200).json({ success: true });

  } catch (error) {
    console.error('❌ Webhook Error:', error.message);
    res.status(400).json({ error: 'Webhook processing failed' });
  }
};
