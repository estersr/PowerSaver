//
//  OnboardingView.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import Foundation
import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            TabView {
                onboardingPage(
                    icon: "battery.100.bolt",
                    title: "Welcome to PowerSaver",
                    description: "Your personal battery health assistant. Get tips to extend battery life and monitor your battery status.",
                    color: .blue
                )
                
                onboardingPage(
                    icon: "lightbulb.fill",
                    title: "Smart Battery Tips",
                    description: "Receive personalized tips based on your current battery status and usage patterns.",
                    color: .yellow
                )
                
                onboardingPage(
                    icon: "heart.fill",
                    title: "Battery Health",
                    description: "Monitor your battery's maximum capacity and get alerts when it's time for maintenance.",
                    color: .pink
                )
                
                onboardingPage(
                    icon: "gear",
                    title: "Quick Actions",
                    description: "One-tap access to battery-saving settings and personalized recommendations.",
                    color: .green
                )
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button(action: {
                dismiss()
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.blue)
                    )
                    .padding(.horizontal, 40)
                    .padding(.bottom, 30)
            }
        }
    }
    
    private func onboardingPage(icon: String, title: String, description: String, color: Color) -> some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(color)
                .symbolRenderingMode(.hierarchical)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}
