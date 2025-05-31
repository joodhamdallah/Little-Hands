const CareGiver = require('../models/CareGiver');
const Booking = require('../models/Booking'); // ✅ Required for booking updates
const BabysitterBookingHandler = require('../services/booking/handlers/BabysitterBookingHandler');

exports.handleStripeWebhook = async (req, res) => {
  try {
    const rawBody = req.body.toString('utf8');
    const event = JSON.parse(rawBody);

    console.log('📦 Received event:', event.type);

    if (event.type !== 'checkout.session.completed') {
      return res.status(200).json({ message: 'Ignored other event type' });
    }

    const session = event.data.object;

    // ✅ CASE 1: Booking Payment (online session)
const bookingId = session?.metadata?.booking_id;

if (bookingId) {
  try {
    // Dummy IO object since we don't have Socket.IO in this context
    const dummyIO = {
      to: () => ({ emit: () => {} }),
    };

    const updatedBooking = await BabysitterBookingHandler.setPaymentMethod(
      bookingId,
      'online',
      dummyIO
    );

    if (!updatedBooking) {
      console.log('❌ Booking not found');
      return res.status(404).json({ message: 'Booking not found' });
    }

    console.log(`✅ Booking ${bookingId} marked as paid & confirmed`);
    return res.status(200).json({ success: true });
  } catch (err) {
    console.error('❌ Failed to confirm booking via handler:', err.message);
    return res.status(500).json({ message: 'Booking confirmation failed' });
  }
}

    // ✅ CASE 2: Caregiver Subscription
    const userId = session.metadata?.user_id;
    const plan = session.metadata?.plan_type;

    if (!userId || !plan) {
      console.log('❌ Missing metadata');
      return res.status(400).json({ message: 'Missing metadata' });
    }

    const updatedCaregiver = await CareGiver.findByIdAndUpdate(
      userId,
      {
        subscription_status: 'paid',
        subscription_type: plan,
      },
      { new: true }
    );

    if (!updatedCaregiver) {
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
