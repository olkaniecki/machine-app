import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

admin.initializeApp();

const stripe = new Stripe(functions.config().stripe.secret, {
  apiVersion: '2025-03-31.basil',
});

interface PaymentData {
  amount: number;
  currency?: string;
}

export const createPaymentIntent = functions.https.onCall(async (request, context) => {
  const data = request.data as PaymentData;
  const amount = data.amount;
  const currency = data.currency || 'usd';

  const paymentIntent = await stripe.paymentIntents.create({
    amount,
    currency,
    automatic_payment_methods: {
      enabled: true,  // Enables Apple Pay, Google Pay, card, etc.
    },
  });

  return {
    clientSecret: paymentIntent.client_secret,
  };
});