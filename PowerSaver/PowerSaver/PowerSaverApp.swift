//
//  PowerSaverApp.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import SwiftUI

@main
struct PowerSaverApp: App {
    @StateObject private var batteryMonitor = BatteryMonitor()
    @State private var showOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(batteryMonitor)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Check if first launch
                    if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                        showOnboarding = false
                    } else {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    }
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView()
                }
        }
    }
}
