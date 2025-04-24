//
//  AuthView.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

/*
 TODO:
    - More account information (favorite songs, payment history)
    - UI design
    - Asset uploads
 
 */

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct AuthView: View {
    @State private var isAuthenticated = false
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        if isAuthenticated {
            HomeView(isAuthenticated: $isAuthenticated)
        } else {
            if showLogin {
                LoginView(showLogin: $showLogin, showRegister: $showRegister, isAuthenticated: $isAuthenticated)
            } else if showRegister {
                RegisterView(showLogin: $showLogin, showRegister: $showRegister, isAuthenticated: $isAuthenticated)
            } else {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("Machine Hub")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.copper)
                        ZStack {
                            Image("CopperLogo")
                                .resizable()
                                .scaledToFit()
                                .ignoresSafeArea()
                                .opacity(0.5)
                            VStack {
                                Button {
                                    showLogin = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Log in")
                                            .padding(.vertical, 10)
                                            .foregroundColor(.copper)
                                        Spacer()
                                    }.background(Color.black)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.copper, lineWidth: 2)
                                        )
                                        .padding()
                                }
                                
                                Button {
                                    showRegister = true
                                } label: {
                                    HStack {
                                        Spacer()
                                        Text("Sign Up")
                                            .padding(.vertical, 10)
                                            .foregroundColor(.copper)
                                        Spacer()
                                    }.background(Color.black)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.copper, lineWidth: 2)
                                        )
                                        .padding()
                                }
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
}

struct LoginView: View {
    @Binding var showLogin: Bool
    @Binding var showRegister: Bool
    @Binding var isAuthenticated: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View{
        ZStack {
            LinearGradient (
                gradient: Gradient(colors: [.black, .black, .copper]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack() {
                Image("CopperLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .padding(.vertical, 10)
                Text("LOG IN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.copper)
                ZStack {
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.7)))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                } .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                ZStack {
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.7)))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                } .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                
                Button {
                    // Checking credientals
                    Auth.auth().signIn(withEmail: email, password: password) {result, error in
                        if let error = error {
                            // Catch error message
                            errorMessage = error.localizedDescription
                        } else {
                            isAuthenticated = true
                            print("Successfully logged in user: \(result?.user.uid ?? "")")
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Log in")
                            .padding(.vertical, 10)
                            
                        Spacer()
                    }.background(Color.black)
                    
                } .cornerRadius(10)
                    .frame(width: 300)
                    
                    
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                Button("Don't have an account? Sign up") {
                    showLogin = false
                    showRegister = true
                } .foregroundColor(.black)
                    .padding()
            }
            .navigationTitle("Machine Log In")
            .padding()
            .foregroundColor(.white)
        }
    }
    
}

struct RegisterView: View {
    @Binding var showLogin: Bool
    @Binding var showRegister: Bool
    @Binding var isAuthenticated: Bool
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    
    var body: some View {
        
        ZStack {
            LinearGradient (
                gradient: Gradient(colors: [.black, .black, .copper]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                Image("CopperLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .padding(.vertical, 10)
                Text("SIGN UP")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.copper)
                ZStack{
                    TextField("", text: $firstName, prompt: Text("First Name").foregroundColor(.white.opacity(0.7)))
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                }.shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                ZStack {
                    TextField("", text: $lastName, prompt: Text("Last Name").foregroundColor(.white.opacity(0.7)))
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                }.shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                ZStack {
                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.white.opacity(0.7)))
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                }.shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                ZStack {
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.7)))
                        .frame(width: 350)
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.copper.opacity(0.3), lineWidth: 2)
                            )
                        .padding()
                }.shadow(color: .black.opacity(0.6), radius: 5, x: 0, y:2)
                
                Button {
                    // Creating user
                    Auth.auth().createUser(withEmail: email, password: password) {result, error in
                        if let error = error {
                            // Catch error message
                            errorMessage = error.localizedDescription
                        } else {
                            guard let uid = Auth.auth().currentUser?.uid else {
                                print("No logged-in user.")
                                return
                            }
                            storeUserData(uid: uid, first_name: firstName, last_name: lastName, email: email, password: password)
                            isAuthenticated = true
                            print("Successfully created user: \(result?.user.uid ?? "")")
                        }
                    }
                } label: {
                    HStack {
                        Spacer()
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        Spacer()
                    }.background(Color.black)
                } .cornerRadius(10)
                    .frame(width: 300)
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                Button("Already have an account? Log in") {
                    showRegister = false
                    showLogin = true
                }.foregroundColor(.black)
                    .padding()
            } .padding()
                .navigationTitle("Machine Register")
                .foregroundColor(.white)
        }
    }
}


// Storing initial user data (UID, name, email, password)
func storeUserData(uid: String, first_name: String, last_name: String, email: String, password: String) {
    let db = Firestore.firestore()
    db.collection("users").document(uid).setData([
        "First Name": first_name,
        "Last Name": last_name,
        "Email": email,
        "Password": password
    ]) { error in
        if let error = error {
            print("Error writing user data: \(error)")
        } else {
            print("User data successfully written.")
        }
    }
}

#Preview {
    AuthView()
}
