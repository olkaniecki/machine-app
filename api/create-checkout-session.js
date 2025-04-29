  // // /api/create-checkout-session.js
  // const stripe = require("stripe")(process.env.STRIPE_SECRET);

  // export default async function handler(req, res) {
  //   if (req.method !== "POST") {
  //     return res.status(405).json({ error: "Method not allowed" });
  //   }

  //   const { productName, amount } = req.body;

  //   try {
  //     const session = await stripe.checkout.sessions.create({
  //       payment_method_types: ["card"],
  //       line_items: [
  //         {
  //           price_data: {
  //             currency: "usd",
  //             product_data: {
  //               name: productName,
  //             },
  //             unit_amount: amount,
  //           },
  //           quantity: 1,
  //         },
  //       ],
  //       mode: "payment",
  //       success_url: "https://example.com/success",
  //       cancel_url: "https://example.com/cancel",
  //     });

  //     return res.status(200).json({
  //       id: session.id,
  //       url: session.url,
  //     });
  //   } catch (error) {
  //     return res.status(500).json({ error: error.message });
  //   }
  // }
  // // This code creates a Stripe checkout session for a product with a specified name and amount.
  // // It handles POST requests and returns the session ID and URL for redirection.
  // // The session is configured for a one-time payment with success and cancel URLs.

  export default function handler(req, res) {
    res.status(200).json({ message: "Hello from API!" });
  }
  