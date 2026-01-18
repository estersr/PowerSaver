//
//  BatteryHealthView.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import SwiftUI
import Combine

struct BatteryHealthView: View {
    @EnvironmentObject var batteryMonitor: BatteryMonitor
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Health Score
                    healthScoreCard
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // Health Indicators
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Health Indicators")
                            .font(.headline)
                            .padding(.horizontal, 5)
                        
                        healthIndicatorRow(
                            title: "Maximum Capacity",
                            value: "\(batteryMonitor.batteryHealth.healthPercentage)%",
                            status: batteryMonitor.batteryHealth.healthStatus,
                            color: batteryMonitor.batteryHealth.healthColor
                        )
                        
                        if let cycleCount = batteryMonitor.batteryHealth.cycleCount {
                            healthIndicatorRow(
                                title: "Cycle Count",
                                value: "\(cycleCount)",
                                status: cycleCount < 500 ? "Good" : "High",
                                color: cycleCount < 500 ? .green : .orange
                            )
                        }
                        
                        healthIndicatorRow(
                            title: "Estimated Capacity",
                            value: "\(batteryMonitor.batteryHealth.currentCapacity)mAh",
                            status: "Design: \(batteryMonitor.batteryHealth.designCapacity)mAh",
                            color: .blue
                        )
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // Health Tips
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Battery Health Tips")
                            .font(.headline)
                            .padding(.horizontal, 5)
                        
                        ForEach(MockBatteryData.tips.filter { $0.category == .charging }.prefix(3)) { tip in
                            healthTipRow(tip: tip)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    // When to Replace
                    VStack(alignment: .leading, spacing: 15) {
                        Text("When to Consider Replacement")
                            .font(.headline)
                            .padding(.horizontal, 5)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            replacementIndicator(
                                condition: "Below 80% capacity",
                                description: "Battery holds significantly less charge",
                                current: batteryMonitor.batteryHealth.healthPercentage < 80
                            )
                            
                            replacementIndicator(
                                condition: "Unexpected shutdowns",
                                description: "Phone turns off at higher battery levels",
                                current: false // Would need actual diagnostics
                            )
                            
                            replacementIndicator(
                                condition: "Slow charging",
                                description: "Takes much longer to charge fully",
                                current: false
                            )
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("Battery Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var healthScoreCard: some View {
        VStack(spacing: 20) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: CGFloat(batteryMonitor.batteryHealth.healthPercentage) / 100)
                    .stroke(
                        batteryMonitor.batteryHealth.healthColor.gradient,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 5) {
                    Text("\(batteryMonitor.batteryHealth.healthPercentage)%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                    
                    Text(batteryMonitor.batteryHealth.healthStatus)
                        .font(.headline)
                        .foregroundColor(batteryMonitor.batteryHealth.healthColor)
                }
            }
            
            Text("Your battery's ability to hold charge compared to when it was new")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
    private func healthIndicatorRow(title: String, value: String, status: String, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color.opacity(0.2))
                )
        }
        .padding(.vertical, 8)
    }
    
    private func healthTipRow(tip: BatteryTip) -> some View {
        HStack(spacing: 15) {
            Image(systemName: tip.icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 5)
    }
    
    private func replacementIndicator(condition: String, description: String, current: Bool) -> some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: current ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundColor(current ? .orange : .green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(condition)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
