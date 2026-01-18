//
//  BatteryMonitor.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class BatteryMonitor: ObservableObject {
    @Published var batteryStatus: BatteryStatus
    @Published var batteryHealth: BatteryHealth
    @Published var currentTip: BatteryTip
    @Published var monitoringTimer: Timer?
    @Published var lastFullChargeDate: Date?
    @Published var estimatedTimeRemaining: TimeInterval?
    
    private let device = UIDevice.current
    
    init() {
        device.isBatteryMonitoringEnabled = true
        
        self.batteryStatus = BatteryStatus(
            level: device.batteryLevel,
            state: device.batteryState,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
            lastUpdated: Date()
        )
        
        self.batteryHealth = UIDevice.estimatedBatteryHealth()
        self.currentTip = MockBatteryData.randomTip()
        
        startMonitoring()
        loadSavedData()
    }
    
    func startMonitoring() {
        monitoringTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            self.updateBatteryStatus()
        }
    }
    
    func updateBatteryStatus() {
        let newStatus = BatteryStatus(
            level: device.batteryLevel,
            state: device.batteryState,
            isLowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled,
            lastUpdated: Date()
        )
        
        if newStatus != batteryStatus {
            batteryStatus = newStatus
            
            // Update tip when battery changes significantly
            if abs(newStatus.level - batteryStatus.level) > 0.05 {
                currentTip = MockBatteryData.randomTip()
            }
            
            // Record last full charge
            if newStatus.level >= 0.99 && newStatus.state == .full {
                lastFullChargeDate = Date()
                saveLastFullChargeDate()
            }
            
            // Estimate time remaining
            estimateTimeRemaining()
        }
    }
    
    func getNewTip() {
        currentTip = MockBatteryData.randomTip()
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func toggleLowPowerMode() {
        // Note: We can't programmatically toggle Low Power Mode
        // This would just open the Settings app
        if let url = URL(string: "App-Prefs:BATTERY_USAGE") {
            UIApplication.shared.open(url)
        }
    }
    
    func openSettingsForTip(_ tip: BatteryTip) {
        guard let action = tip.action else { return }
        
        var urlString = "App-Prefs:"
        
        switch action {
        case "Open Control Center":
            // Can't open Control Center programmatically
            return
        case "Open Settings":
            urlString = "App-Prefs:"
        case "Display & Brightness":
            urlString = "App-Prefs:DISPLAY"
        case "General → Background App Refresh":
            urlString = "App-Prefs:General&path=BACKGROUND_APP_REFRESH"
        case "Privacy → Location Services":
            urlString = "App-Prefs:Privacy&path=LOCATION"
        case "Notifications":
            urlString = "App-Prefs:NOTIFICATIONS_ID"
        case "Software Update":
            urlString = "App-Prefs:General&path=SOFTWARE_UPDATE_LINK"
        case "Display & Brightness → Auto-Lock":
            urlString = "App-Prefs:DISPLAY&path=AUTOLOCK"
        case "Battery → Battery Health":
            urlString = "App-Prefs:BATTERY_USAGE"
        default:
            urlString = "App-Prefs:"
        }
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func estimateTimeRemaining() {
        // Very rough estimation based on battery level and state
        // In a real app, you'd use more sophisticated calculation
        
        guard batteryStatus.state == .unplugged else {
            estimatedTimeRemaining = nil
            return
        }
        
        // Assuming average iPhone battery life of 8-12 hours
        let averageBatteryLife: TimeInterval = 10 * 3600 // 10 hours in seconds
        estimatedTimeRemaining = TimeInterval(batteryStatus.level) * averageBatteryLife
    }
    
    private func loadSavedData() {
        if let savedDate = UserDefaults.standard.object(forKey: "lastFullChargeDate") as? Date {
            lastFullChargeDate = savedDate
        }
    }
    
    private func saveLastFullChargeDate() {
        if let date = lastFullChargeDate {
            UserDefaults.standard.set(date, forKey: "lastFullChargeDate")
        }
    }
    
    func getTipsForCurrentStatus() -> [BatteryTip] {
        var relevantTips: [BatteryTip] = []
        
        if batteryStatus.levelPercentage <= 20 {
            relevantTips = MockBatteryData.tips.filter { $0.impact == .high }
        } else if batteryStatus.isLowPowerMode {
            relevantTips = MockBatteryData.tips.filter { $0.impact == .high || $0.impact == .medium }
        } else {
            relevantTips = MockBatteryData.tips.shuffled()
        }
        
        return Array(relevantTips.prefix(5))
    }
    
    deinit {
        monitoringTimer?.invalidate()
    }
}
