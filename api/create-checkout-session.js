// /api/create-checkout-session.js
require("dotenv").config();
const stripe = require("stripe")(process.env.STRIPE_SECRET);

export default async function handler(req, res) {
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Method not allowed" });
  }

  const { productName, amount } = req.body;

  if (!productName || !amount) {
    console.error("Missing parameters: productName or amount");
    return res.status(400).json({ error: "Missing productName or amount" });
  }

  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "usd",
            product_data: {
              name: productName,
            },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: "https://example.com/success",
      cancel_url: "https://example.com/cancel",
    });

    return res.status(200).json({
      id: session.id,
      url: session.url,
    });
  } catch (error) {
    console.error("Error creating Stripe session:", error);
    return res.status(500).json({ error: error.message });
  }
}
