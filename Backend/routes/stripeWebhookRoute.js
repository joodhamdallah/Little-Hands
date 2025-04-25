const express = require('express');
const router = express.Router();
const bodyParser = require('body-parser');
const stripeWebhookController = require('../controllers/stripeWebhookController'); 

// Webhook route
router.post(
  '/webhook',
  bodyParser.raw({ type: 'application/json' }),
  stripeWebhookController.handleStripeWebhook
);

// use the one below if u wanna test on postman 

//router.post('/webhook', express.json(), stripeWebhookController.handleStripeWebhook);

module.exports = router;
