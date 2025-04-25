// services/stripeService.js
const Stripe = require('stripe');
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

async function createCheckoutSession(userId, plan) {
  const prices = {
    monthly: 'price_1RHoQ9R769NbdzCKnnxmOvuD',
    quarterly: 'price_1RHoWKR769NbdzCKik5vb4WV',
    annual: 'price_1RHoVPR769NbdzCKZOyG8ldv'
  };

  const priceId = prices[plan];
  if (!priceId) throw new Error('Invalid plan selected');

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    mode: 'subscription',
    line_items: [
      {
        price: priceId,
        quantity: 1,
      },
    ],
    success_url: `${process.env.CLIENT_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.CLIENT_URL}/cancel`,
    metadata: {
      user_id: userId,
      plan_type: plan,
    },
  });

  return session;
}

module.exports = {
  createCheckoutSession,
};
