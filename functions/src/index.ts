import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();

const stripe = new Stripe(functions.config().stripe.secret, {
  apiVersion: "2025-04-30.basil",
});

interface PaymentData {
  amount: number;
  currency?: string;
}

export const createPaymentIntent = functions.region("us-east4")
  .https.onCall(async (request) => {
    const data = request.data as PaymentData;
    const amount = data.amount;
    const currency = data.currency || "usd";

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    return {
      clientSecret: paymentIntent.client_secret,
    };
  });
