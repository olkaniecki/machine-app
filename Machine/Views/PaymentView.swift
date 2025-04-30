// Payment View for TicketView


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit
//import FirebaseFunctions
import Stripe

struct PaymentView: View {

    @State private var paymentSheet: PaymentSheet?  // Stripe Pre-built Payment UI
    @State private var isLoading = false    // Loading variable for payment processing
    @State private var ticketTotalinCents: Int = 0
    @State private var errorMessage: String?
    
    var event: Event
    
    let functions = Functions.functions()

    var body: some View {
        VStack(spacing: 10) {
            // Placeholder Text for debugging
            Text("Event: \(event.name)")
                .font(.title2)
            Text("Your total: $\(event.price).00")
                .font(.title)
            
            if let error = errorMessage {
                    Text(error)
                    .foregroundColor(.red)
            }
            
            // Pay Button
            Button(action: {
                fetchPaymentIntent()
            }) {
                if isLoading {
                    //TODO: Make this a custom Progress View
                    ProgressView()
                } else {
                    Text("Pay $\(event.price).00")
                }
            }
            .disabled(isLoading)
        }
        .padding()
        .onAppear {
            // Calculate the ticket price into cents for Stripe to recognize it
            ticketTotalinCents = event.price * 100
        }
    }

    func fetchPaymentIntent() {
        isLoading = true
        errorMessage = nil
        
        functions.httpsCallable("createPaymentIntent").call(["amount": ticketTotalinCents]) { result, error in
            if let error = error {
                print("Error fetching payment intent: \(error)")
                return
            }

            if let data = result?.data as? [String: Any],
               let clientSecret = data["clientSecret"] as? String {
                let configuration = PaymentSheet.Configuration()
                configuration.merchantDisplayName = "Machine-Hub"
                self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
            } else {
                errorMessage = "Unable to parse ClientSecret"
            }
        
        }
    }

    func presentPaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Machine-Hub"
        configuration.applePay = .init(merchantId: "merchant.com.machinehub", merchantCountryCode: "US")
        self.paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
        self.paymentSheet?.present(from: self) { result in
            switch result {
            case .completed:
                print("✅ Payment completed")
            case .canceled:
                print("⚠️ Payment canceled")
            case .failed(let error):
                print("❌ Payment failed: \(error)")
            }
        }
    }

}
