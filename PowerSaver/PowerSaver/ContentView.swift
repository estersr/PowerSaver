//
//  ContentView.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var batteryMonitor: BatteryMonitor
    @State private var selectedCategory: BatteryTip.TipCategory = .general
    @State private var showingAllTips = false
    @State private var showingHealthDetails = false
    @State private var showingSettings = false
    @State private var pulseAnimation = false
    
    var timeRemainingString: String? {
        guard let time = batteryMonitor.estimatedTimeRemaining else { return nil }
        
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "~\(hours)h \(minutes)m"
        } else {
            return "~\(minutes)m"
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient based on battery level
                LinearGradient(
                    colors: [
                        batteryMonitor.batteryStatus.color.opacity(0.3),
                        Color(.systemBackground).opacity(0.8)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Battery Status Card
                        batteryStatusCard
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        // Daily Tip
                        dailyTipCard
                            .padding(.horizontal, 20)
                        
                        // Quick Actions
                        quickActionsGrid
                            .padding(.horizontal, 20)
                        
                        // Category Filters
                        categoryFilter
                            .padding(.horizontal, 20)
                        
                        // Filtered Tips
                        filteredTipsGrid
                            .padding(.horizontal, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("PowerSaver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingHealthDetails.toggle() }) {
                        Image(systemName: "heart.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingHealthDetails) {
                BatteryHealthView()
                    .environmentObject(batteryMonitor)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .refreshable {
                batteryMonitor.updateBatteryStatus()
            }
        }
    }
    
    private var batteryStatusCard: some View {
        VStack(spacing: 20) {
            // Battery Icon and Percentage
            HStack(alignment: .center, spacing: 15) {
                Image(systemName: batteryMonitor.batteryStatus.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(batteryMonitor.batteryStatus.color)
                    .symbolRenderingMode(.hierarchical)
                    .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: pulseAnimation
                    )
                    .onAppear {
                        pulseAnimation = true
                    }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(batteryMonitor.batteryStatus.levelPercentage)%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    
                    HStack(spacing: 10) {
                        Label(batteryMonitor.batteryStatus.stateDescription,
                              systemImage: batteryMonitor.batteryStatus.state == .charging ? "bolt.fill" : "battery.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if batteryMonitor.batteryStatus.isLowPowerMode {
                            Label("Low Power Mode", systemImage: "bolt.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Battery Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .frame(height: 20)
                    
                    // Battery Level
                    RoundedRectangle(cornerRadius: 10)
                        .fill(batteryMonitor.batteryStatus.color.gradient)
                        .frame(width: geometry.size.width * CGFloat(batteryMonitor.batteryStatus.level),
                               height: 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: batteryMonitor.batteryStatus.level)
                    
                    // Markers
                    ForEach(0..<5) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 2, height: 20)
                            .offset(x: geometry.size.width * CGFloat(i) * 0.25 - 1)
                    }
                }
            }
            .frame(height: 20)
            
            // Additional Info
            HStack {
                if let timeString = timeRemainingString {
                    Label(timeString, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let lastCharge = batteryMonitor.lastFullChargeDate {
                    Text("Last full: \(lastCharge, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("Daily Tip", systemImage: "lightbulb.fill")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Button(action: batteryMonitor.getNewTip) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Image(systemName: batteryMonitor.currentTip.icon)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(batteryMonitor.currentTip.title)
                            .font(.headline)
                        
                        Text(batteryMonitor.currentTip.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                HStack {
                    Text(batteryMonitor.currentTip.impact.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(batteryMonitor.currentTip.impactColor.opacity(0.2))
                        )
                    
                    Spacer()
                    
                    if let action = batteryMonitor.currentTip.action {
                        Button(action: {
                            batteryMonitor.openSettingsForTip(batteryMonitor.currentTip)
                        }) {
                            Text(action)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal, 5)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                quickActionButton(
                    title: batteryMonitor.batteryStatus.isLowPowerMode ? "Low Power Mode" : "Enable Low Power",
                    icon: batteryMonitor.batteryStatus.isLowPowerMode ? "bolt.fill" : "bolt.slash",
                    color: batteryMonitor.batteryStatus.isLowPowerMode ? .orange : .blue,
                    action: batteryMonitor.toggleLowPowerMode
                )
                
                quickActionButton(
                    title: "Refresh",
                    icon: "arrow.clockwise",
                    color: .green,
                    action: batteryMonitor.updateBatteryStatus
                )
                
                quickActionButton(
                    title: "All Tips",
                    icon: "list.bullet",
                    color: .purple,
                    action: { showingAllTips = true }
                )
                
                quickActionButton(
                    title: "Battery Health",
                    icon: "heart.fill",
                    color: .pink,
                    action: { showingHealthDetails = true }
                )
            }
        }
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal, 5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(BatteryTip.TipCategory.allCases, id: \.self) { category in
                        categoryButton(category: category)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    private func categoryButton(category: BatteryTip.TipCategory) -> some View {
        Button(action: {
            selectedCategory = category
        }) {
            HStack(spacing: 6) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(MockBatteryData.filteredTips(for: category).count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Circle().fill(Color.secondary.opacity(0.2)))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(selectedCategory == category ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        Capsule()
                            .stroke(selectedCategory == category ? Color.blue : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var filteredTipsGrid: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("\(selectedCategory.rawValue) Tips")
                    .font(.headline)
                
                Spacer()
                
                Text("\(MockBatteryData.filteredTips(for: selectedCategory).count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 5)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(MockBatteryData.filteredTips(for: selectedCategory).prefix(6)) { tip in
                    tipCard(tip: tip)
                }
            }
            
            if MockBatteryData.filteredTips(for: selectedCategory).count > 6 {
                Button("Show All \(selectedCategory.rawValue) Tips") {
                    showingAllTips = true
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
        }
    }
    
    private func tipCard(tip: BatteryTip) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tip.icon)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Spacer()
                
                Text(tip.impact.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(tip.impactColor.opacity(0.2))
                    )
            }
            
            Text(tip.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Spacer()
            
            if let action = tip.action {
                Button(action: {
                    batteryMonitor.openSettingsForTip(tip)
                }) {
                    Text(action)
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                }
            }
        }
        .padding(15)
        .frame(height: 140)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
}

// Additional views would be created similarly...
