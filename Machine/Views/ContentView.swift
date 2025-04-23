//
//  ContentView.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

import SwiftUI


// Navigation Bar 
struct ContentView: View {
    @State private var isAuthenticated = true
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
            TicketView()
                .tabItem{
                    Label("Events", systemImage: "square")
                }.tag(0)
            HomeView(isAuthenticated: $isAuthenticated)
                .tabItem{
                    Label("Music", systemImage: "square")
                }.tag(1)
            MerchView()
                .tabItem {
                    Label("Merch", systemImage: "square")
                }.tag(2)
            SettingsView()
                .tabItem{
                    Label("Settings", systemImage: "square")
                }
            
            
            
        }
    }
}

#Preview {
    ContentView()
}
