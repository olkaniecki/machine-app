// Payment View for TicketView


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit
import FirebaseFunctions
import Stripe
import StripePaymentSheet

struct PaymentView: View {

    @State private var paymentSheet: PaymentSheet?  // Stripe Pre-built Payment UI
    @State private var isLoading = false    // Loading variable for payment processing
    @State private var ticketTotalinCents: Int = 0
    @State private var errorMessage: String?
    @State private var showStripeSheet = false
    @State private var clientSecret: String? = nil
    
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
        .sheet(isPresented: $showStripeSheet) {
            if let clientSecret = clientSecret {
                StripePaymentSheetView(clientSecret: clientSecret) { result in
                    
                    showStripeSheet = false
                    switch result {
                    case .completed:
                        print("✅ Payment completed")
                        logPaymentToFirestore()
                    case .canceled:
                        print("⚠️ Payment canceled")
                    case .failed(let error):
                        print("❌ Payment failed: \(error)")
                    }

                    
                }
            }
        }
        .onAppear {
            // Calculate the ticket price into cents for Stripe to recognize it
            ticketTotalinCents = event.price * 100
        }
    }

    func fetchPaymentIntent() {
        isLoading = true
        errorMessage = nil
        
        functions.httpsCallable("createPaymentIntent").call(["amount": ticketTotalinCents]) { result, error in
            isLoading = false // reset loading status
            if let error = error {
                print("Error fetching payment intent: \(error)")
                return
            }

            if let data = result?.data as? [String: Any],
               let clientSecret = data["clientSecret"] as? String {
                self.clientSecret = clientSecret
                self.showStripeSheet = true
            } else {
                errorMessage = "Unable to parse ClientSecret"
            }
        
        }
    }
    
    func logPaymentToFirestore() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("❌ No authenticated user found.")
            return
        }
        
        let db = Firestore.firestore()
        let paymentInfo: [String: Any] = [
            "userID": userID,
            "eventID": event.id,
            "eventName": event.name,
            "amount": ticketTotalinCents / 100,
            "timeStamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("payments").addDocument(data: paymentInfo) { error in
            if let error = error {
                print("❌ Failed to log payment: \(error.localizedDescription)")
            } else {
                print("✅ Payment logged successfully in Firestore")
            }
        }
    }
}

struct StripePaymentSheetView: UIViewControllerRepresentable {
    let clientSecret: String
    var onCompletion: (PaymentSheetResult) -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        
        DispatchQueue.main.async {
                    var config = PaymentSheet.Configuration()
                    config.merchantDisplayName = "Machine-Hub"
                    config.applePay = .init(merchantId: "merchant.com.machinehub", merchantCountryCode: "US")
                    
                    let sheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
                    sheet.present(from: vc) { result in
                        onCompletion(result)
                    }
                }

                return vc
            }

            func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
        
    }
