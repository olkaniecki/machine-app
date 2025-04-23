//
//  MachineApp.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

import SwiftUI
import FirebaseCore

// Connecting Firebase at startup
class AppDelegate : NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct MachineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
