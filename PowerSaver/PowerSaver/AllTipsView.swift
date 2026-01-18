//
//  AllTipsView.swift
//  PowerSaver
//
//  Created by Esther Ramos on 17/01/26.
//

import SwiftUI

struct AllTipsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: BatteryTip.TipCategory?
    
    var filteredTips: [BatteryTip] {
        var tips = MockBatteryData.tips
        
        if let category = selectedCategory {
            tips = tips.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            tips = tips.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return tips
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredTips) { tip in
                    tipRow(tip: tip)
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("All Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("All Categories") {
                            selectedCategory = nil
                        }
                        
                        Divider()
                        
                        ForEach(BatteryTip.TipCategory.allCases, id: \.self) { category in
                            Button(category.rawValue) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func tipRow(tip: BatteryTip) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tip.icon)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(tip.title)
                        .font(.headline)
                    
                    Text(tip.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(tip.impact.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(tip.impactColor.opacity(0.2))
                    )
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let action = tip.action {
                Button(action: {
                    // In a real app, this would open settings
                }) {
                    Text(action)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
