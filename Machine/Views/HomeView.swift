//
//  HomeView.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

import SwiftUI
import MusicKit
import MediaPlayer

/*
 TODO:
 
 - Pay $99/year to just integrate Music with this app lol
 */


struct HomeView: View {
    
    @Binding var isAuthenticated: Bool
    @State private var artistID: String = "20914088"
    @State private var albums: [Album] = []
    
    var body: some View {
        Text("Home View")
        
        
        
        
        
        
        
    }
}



// Requesting Apple Music permission
func requestAppleMusicPermission() {
    Task {
        do {
            let status = await MusicAuthorization.request()
            
            switch status {
            case .authorized:
                print("Apple MusicKit -- Music access granted.")
            case .denied:
                print("Apple MusicKit -- Music access denied.")
            case .restricted:
                print("Apple MusicKit -- Music access restricted.")
            case .notDetermined:
                print("Apple MusicKit -- Music access not determined yet.")
            @unknown default:
                break
            }
        }
    }
    
}




