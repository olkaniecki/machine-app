//
//  TicketView.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//


import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

// Event Data Structure
struct Event: Identifiable {
    var id: String
    var name: String
    var price: Int
    var date: Date
    var location: String
    var description: String
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
                    
                    return Event(id: id, name: name, price: price, date: date, location: location, description: description)
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
                    
                    // Purchased Tickets Header
                    PurchasedTicketView()
                    // Upcoming Events Header
                    EventView()
                    
                }
                
            }.background(Color.black)
        }
    }
}

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
                    VStack{
                        Text(event.name)
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(event.date, style: .date)
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Text("$\(event.price)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        Text(event.description)
                            .foregroundColor(.white)
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
            viewModel.fetchEvents()
        }
    }
}

struct DetailTicketView: View {
    let ticket: Ticket
    
    var body: some View {
        VStack {}
    }
}

struct DetailEventView: View {
    let event: Event
    
    var body: some View {
        VStack {
            Text(event.name)
                .foregroundColor(.white)
                .font(.title)
            Text("$\(event.price)")
                .foregroundColor(.white)
                .font(.subheadline)
            Text(event.date, style: .date)
                .foregroundColor(.white)
                .font(.headline)
            
            
        }.background(Color.black)
    }
}

struct CheckoutTicketView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}


#Preview {
    TicketView()
}
