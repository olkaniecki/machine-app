//
//  TicketView.swift
//
//  Hub for available events, ticket purchasing, and ticket display on Apple Wallet


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

// Event Data Structure
struct Event: Identifiable {
    var id: String
    var name: String
    var price: Int
    var date: Date
    var location: String
    var description: String
    var image: String
}

// Ticket Data Structure
struct Ticket: Identifiable {
    var id: String
    var userID: String
    var eventID: String
    var eventName: String
    var isUsed: Bool
    var purchaseDate: Date
    var qrCode: String
}


// Firestore Database Event Fetching
class EventModel: ObservableObject {
    @Published var events: [Event] = []
    
    private var db = Firestore.firestore()
    
    // Communicates with Firestore Database to grab events
    func fetchEvents() {
        db.collection("events")
            .getDocuments { (snapshot, error) in
                // Error handling if events cannot be fetched
                if let error = error {
                    print("Error fetching events: \(error)")
                    return
                }
                
                // Parsing data into Event struct variables
                self.events = snapshot?.documents.compactMap{ document -> Event? in
                    let data = document.data()
                    let id = document.documentID
                    let name = data["Event Name"] as? String ?? ""
                    let price = data["Price"] as? Int ?? 0
                    let timestamp = data["Date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()
                    let location = data["Address"] as? String ?? ""
                    let description = data["Description"] as? String ?? ""
                    let image = data["Image"] as? String ?? ""
                    
                    return Event(id: id, name: name, price: price, date: date, location: location, description: description, image: image)
                } ?? []
            }
    }
}

// Firestore Database Purchased Ticket Fetching
class PurchasedTicketModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    
    private var db = Firestore.firestore()
    
    // Communicates with Firestore Database to grab purchased tickets
    func fetchTickets() {
        db.collection("purchased_tickets").whereField("userID", isEqualTo: Auth.auth().currentUser?.uid ?? "").getDocuments{ (snapshot, error) in
            if let error = error {
                // Error handling if tickets cannot be fetched
                print("Error fetching purchased tickets: \(error)")
                return
            }
            
            // Parsing data into Ticket struct variables
            self.tickets = snapshot?.documents.compactMap{ document in
                let data = document.data()
                let id = document.documentID
                let userID = data["userID"] as? String ?? ""
                let eventID = data["eventID"] as? String ?? ""
                let eventName = data["eventName"] as? String ?? ""
                let isUsed = data["isUsed"] as? Bool ?? false
                let timestamp = data["purchaseDate"] as? Timestamp
                let purchaseDate = timestamp?.dateValue() ?? Date()
                let qrCode = data["qrCode"] as? String ?? ""
                
                
                return Ticket(id: id, userID: userID, eventID: eventID, eventName: eventName, isUsed: isUsed, purchaseDate: purchaseDate, qrCode: qrCode)
            } ?? []
            
        }
    }
}

struct TicketView: View {
    var body: some View {
        NavigationView {
            ScrollView{
                VStack(alignment: .leading) {
                    // Header
                    HStack {
                        Image("CopperLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 170, height: 130)
                        Text("EVENTS")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.copper)
                    } .padding()
                    
                    // Purchased Tickets
                    PurchasedTicketView()
                    // Upcoming Events
                    EventView()
                }
                
            }.background(Color.black)
        }.tint(.copper)
    }
}


// List of Purchased Tickets given UID
struct PurchasedTicketView: View {
    @StateObject var purchaseModel = PurchasedTicketModel()
    
    var body: some View {
        VStack {
        Text("My Events")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.copper)
            .padding(.horizontal)
        
        // No Purchased Tickets Empty Condition
        if purchaseModel.tickets.isEmpty {
            Text("No purchased tickets.")
                .foregroundColor(.gray)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // List of Purchased Tickets
            ForEach(purchaseModel.tickets) { ticket in
                NavigationLink(destination: DetailTicketView(ticket: ticket)) {
                    VStack{
                        Text(ticket.eventName)
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(ticket.purchaseDate, style: .date)
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(minWidth: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                
            }
        }
        } .onAppear {
            purchaseModel.fetchTickets()
        }

    }
}

struct EventView: View {
    @StateObject var viewModel = EventModel()

    var body: some View {
        VStack {
        Text("Upcoming Events")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.copper)
            .padding(.horizontal)
        // No Upcoming Events Empty Condition
        if viewModel.events.isEmpty {
            Text("No upcoming events.")
                .foregroundColor(.gray)
                .padding(.vertical)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // List of Upcoming Events
            ForEach(viewModel.events) { event in
                NavigationLink(destination: DetailEventView(event: event)) {
                        HStack{
                            // Event Image Display
                            if let url = URL(string: event.image) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty:
                                        Text("Empty")
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 150, height: 150)
                                            .padding(.vertical)
                                    case .failure:
                                        Text("Failed to load image.")
                                    @unknown default:
                                        Text("unknown default")
                                    }
                                }
                            }
                            VStack(alignment: .leading) {
                                Text(event.name)
                                    .foregroundColor(.white)
                                    .font(.title2)
                                Text(event.date, style: .date)
                                    .foregroundColor(.copper)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("$\(event.price)")
                                    .foregroundColor(.copper)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                Text(event.description)
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                    .lineLimit(3)
                                    .truncationMode(.tail)
                                    .multilineTextAlignment(.leading)
                                    .padding(.horizontal, 5)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        } .onAppear {
            viewModel.fetchEvents()
        }
    }
}

struct DetailTicketView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack {
            
        }
    }
}

struct DetailEventView: View {
    let event: Event
    
    var body: some View {
        ZStack {
            LinearGradient (
                gradient: Gradient(colors: [.black, .black, .copper]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            ScrollView {
                VStack{
                    if let url = URL(string: event.image) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Text("Empty")
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 350, height: 350)
                            case .failure:
                                Text("Failed to load image.")
                            @unknown default:
                                Text("unknown default")
                            }
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Text(event.name)
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("$\(event.price).00")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(Color.copper.opacity(0.3))
                            .cornerRadius(40)
                            .fontWeight(.bold)
                    }
                    
                    
                    (Text("Event Date: ").bold() + Text("\(formattedDate)"))
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(10)
                    (Text("Location: ").bold() + Text("\(event.location)"))
                        .padding(10)
                        .foregroundColor(.white)
                        .font(.title3)
                }.background(Color.black.opacity(0.3))
                    .cornerRadius(25)
                    .padding()
                    .frame(width: 350)
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: CheckoutTicketView(event: event)) {
                    HStack {
                        Text("Buy Ticket")
                            .font(.title2)
                            .padding()
                            .foregroundColor(.white)
                        Image(systemName: "cart")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .frame(width: 350)
                    .padding(.horizontal)
                    .background(Color.black)
                    .cornerRadius(40)
                }.frame(maxWidth: .infinity)
                    .navigationTitle("Event")
                
            }
        }
        }
    var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy 'at' h:mm a"
            return formatter.string(from: event.date)
        }
}


struct CheckoutTicketView: View {
    let event: Event
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}


#Preview {
    TicketView()
}
