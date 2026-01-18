//
//  BatteryInfo.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import Foundation
import SwiftUI
import UIKit

struct BatteryStatus: Equatable {
    let level: Float
    let state: UIDevice.BatteryState
    let isLowPowerMode: Bool
    let lastUpdated: Date
    
    var levelPercentage: Int {
        Int(level * 100)
    }
    
    var iconName: String {
        switch state {
        case .charging, .full:
            return "battery.100.bolt"
        case .unplugged:
            if levelPercentage >= 75 {
                return "battery.100"
            } else if levelPercentage >= 50 {
                return "battery.75"
            } else if levelPercentage >= 25 {
                return "battery.50"
            } else if levelPercentage >= 10 {
                return "battery.25"
            } else {
                return "battery.0"
            }
        default:
            return "battery.100"
        }
    }
    
    var stateDescription: String {
        switch state {
        case .charging:
            return "Charging"
        case .full:
            return "Fully Charged"
        case .unplugged:
            return "On Battery"
        default:
            return "Unknown"
        }
    }
    
    var color: Color {
        if isLowPowerMode {
            return .orange
        }
        
        switch levelPercentage {
        case 0...20:
            return .red
        case 21...50:
            return .orange
        case 51...80:
            return .yellow
        case 81...100:
            return .green
        default:
            return .gray
        }
    }
}

struct BatteryTip: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let category: TipCategory
    let impact: ImpactLevel
    let action: String?
    
    enum TipCategory: String, CaseIterable {
        case brightness = "Brightness"
        case connectivity = "Connectivity"
        case apps = "Apps & Services"
        case settings = "Settings"
        case charging = "Charging"
        case general = "General"
    }
    
    enum ImpactLevel: String {
        case high = "High Impact"
        case medium = "Medium Impact"
        case low = "Low Impact"
    }
    
    var impactColor: Color {
        switch impact {
        case .high: return .green
        case .medium: return .yellow
        case .low: return .blue
        }
    }
}

struct BatteryHealth: Equatable {
    let designCapacity: Int
    let currentCapacity: Int
    let cycleCount: Int?
    let maximumCapacityPercentage: Int
    
    var healthPercentage: Int {
        maximumCapacityPercentage
    }
    
    var healthStatus: String {
        switch healthPercentage {
        case 80...100:
            return "Excellent"
        case 70..<80:
            return "Good"
        case 60..<70:
            return "Fair"
        default:
            return "Poor"
        }
    }
    
    var healthColor: Color {
        switch healthPercentage {
        case 80...100:
            return .green
        case 70..<80:
            return .yellow
        case 60..<70:
            return .orange
        default:
            return .red
        }
    }
}

// Mock data for simulator
class MockBatteryData {
    static let tips: [BatteryTip] = [
        BatteryTip(
            title: "Reduce Screen Brightness",
            description: "Lowering your screen brightness by 20% can save up to 30% of battery life.",
            icon: "sun.max",
            category: .brightness,
            impact: .high,
            action: "Open Control Center"
        ),
        BatteryTip(
            title: "Turn Off Bluetooth",
            description: "Bluetooth constantly searches for devices, draining battery even when not in use.",
            icon: "bluetooth",
            category: .connectivity,
            impact: .medium,
            action: "Open Settings"
        ),
        BatteryTip(
            title: "Enable Auto-Brightness",
            description: "Let your iPhone adjust brightness automatically based on ambient light.",
            icon: "lightbulb",
            category: .brightness,
            impact: .medium,
            action: "Display & Brightness"
        ),
        BatteryTip(
            title: "Use Wi-Fi Instead of Cellular",
            description: "Wi-Fi uses less power than cellular data, especially in areas with poor signal.",
            icon: "wifi",
            category: .connectivity,
            impact: .high,
            action: nil
        ),
        BatteryTip(
            title: "Close Background Apps",
            description: "Apps running in background can drain battery. Swipe them away when not needed.",
            icon: "app.badge",
            category: .apps,
            impact: .medium,
            action: "Swipe Up & Close"
        ),
        BatteryTip(
            title: "Disable Background App Refresh",
            description: "Prevent apps from refreshing content in background unnecessarily.",
            icon: "arrow.clockwise",
            category: .settings,
            impact: .medium,
            action: "General → Background App Refresh"
        ),
        BatteryTip(
            title: "Turn Off Location Services",
            description: "Only enable location services for apps that really need it.",
            icon: "location",
            category: .settings,
            impact: .high,
            action: "Privacy → Location Services"
        ),
        BatteryTip(
            title: "Reduce Notifications",
            description: "Each notification wakes your screen. Limit them to essential apps.",
            icon: "bell.badge",
            category: .apps,
            impact: .low,
            action: "Notifications"
        ),
        BatteryTip(
            title: "Use Dark Mode",
            description: "On OLED screens, dark mode can significantly reduce power consumption.",
            icon: "moon.fill",
            category: .brightness,
            impact: .medium,
            action: "Display & Brightness"
        ),
        BatteryTip(
            title: "Avoid Extreme Temperatures",
            description: "Batteries degrade faster in very hot or cold environments.",
            icon: "thermometer",
            category: .charging,
            impact: .high,
            action: nil
        ),
        BatteryTip(
            title: "Update to Latest iOS",
            description: "Apple often includes battery optimization improvements in updates.",
            icon: "gear",
            category: .general,
            impact: .medium,
            action: "Software Update"
        ),
        BatteryTip(
            title: "Limit Widgets & Live Activities",
            description: "Widgets and live activities that update frequently consume more battery.",
            icon: "square.grid.2x2",
            category: .apps,
            impact: .low,
            action: nil
        ),
        BatteryTip(
            title: "Reduce Auto-Lock Time",
            description: "Set auto-lock to 30 seconds or 1 minute to turn off screen faster.",
            icon: "lock",
            category: .settings,
            impact: .medium,
            action: "Display & Brightness → Auto-Lock"
        ),
        BatteryTip(
            title: "Disable Raise to Wake",
            description: "This feature activates the screen whenever you pick up your phone.",
            icon: "hand.raised",
            category: .settings,
            impact: .low,
            action: "Display & Brightness"
        ),
        BatteryTip(
            title: "Optimize Charging",
            description: "Enable Optimized Battery Charging to learn your routine and reduce wear.",
            icon: "bolt.fill",
            category: .charging,
            impact: .high,
            action: "Battery → Battery Health"
        )
    ]
    
    static func randomTip() -> BatteryTip {
        tips.randomElement() ?? tips[0]
    }
    
    static func filteredTips(for category: BatteryTip.TipCategory) -> [BatteryTip] {
        tips.filter { $0.category == category }
    }
}

// For battery health estimation (simulator only)
extension UIDevice {
    static func estimatedBatteryHealth() -> BatteryHealth {
        // Note: Actual battery health data is private on iOS
        // This is an estimation for demo purposes
        let designCapacity = 3000 // mAh - typical iPhone battery
        let maximumCapacityPercentage = Int.random(in: 75...100)
        let currentCapacity = designCapacity * maximumCapacityPercentage / 100
        let cycleCount = Int.random(in: 100...500)
        
        return BatteryHealth(
            designCapacity: designCapacity,
            currentCapacity: currentCapacity,
            cycleCount: cycleCount,
            maximumCapacityPercentage: maximumCapacityPercentage
        )
    }
}
