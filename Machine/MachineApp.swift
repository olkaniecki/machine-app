//
//  MachineApp.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

import SwiftUI
import FirebaseCore
import Stripe

// Connecting Firebase at startup
class AppDelegate : NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Stripe Publishable Key
        STPAPIClient.shared.publishableKey = "pk_live_51RJIaUKOgIBJzpBEq4d1JmVyM6Zxog0Gml3YcQRdZ5tl19v0pt61zY8E6ZkMRp0LQKHLKhPJinpmO3XMSCigoSI400fjHHFomj"
        
        let appearance = UINavigationBarAppearance()

        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.orange]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.orange]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor.gray
        return true
    }
}

@main
struct MachineApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AuthView()
        }
    }
}
