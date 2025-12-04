//
//  StatItemView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct StatItemView: View {
    let title: String
    let value: String
    var icon: String? = nil
    var color: Color = .primary
    
    var body: some View {
        VStack(spacing: 8) {
            if let icon = icon {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                }
            } else {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HStack {
        StatItemView(title: "Total\nCompletions", value: "145", icon: "checkmark.circle.fill", color: .green)
        StatItemView(title: "Current\nStreak", value: "12", icon: "flame.fill", color: .orange)
    }
    .padding()
}
