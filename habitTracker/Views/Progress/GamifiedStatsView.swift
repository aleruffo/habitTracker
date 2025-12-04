//
//  GamifiedStatsView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct GamifiedStatsView: View {
    @EnvironmentObject private var habitStore: HabitStore
    
    private var levelIcon: String {
        switch habitStore.userProfile.level {
        case 1: return "leaf.fill"
        case 2: return "flame.fill"
        case 3: return "star.fill"
        case 4: return "bolt.fill"
        case 5: return "crown.fill"
        case 6: return "sparkles"
        case 7: return "moon.stars.fill"
        case 8: return "trophy.fill"
        default: return "star.fill"
        }
    }
    
    private var levelColor: Color {
        switch habitStore.userProfile.level {
        case 1: return .green
        case 2: return .orange
        case 3: return .yellow
        case 4: return .blue
        case 5: return .purple
        case 6: return .pink
        case 7: return .indigo
        case 8: return .yellow
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Level Progress")
                    .font(.headline)
                
                Spacer()
                
                // Level badge
                HStack(spacing: 6) {
                    Image(systemName: levelIcon)
                        .foregroundStyle(levelColor)
                    Text("Lv. \(habitStore.userProfile.level)")
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(levelColor.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Level title and progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(habitStore.userProfile.levelTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(Int(habitStore.userProfile.levelProgress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(.secondarySystemBackground))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [levelColor.opacity(0.8), levelColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * habitStore.userProfile.levelProgress, height: 12)
                    }
                }
                .frame(height: 12)
                
                // Progress details
                if habitStore.userProfile.completionsToNextLevel > 0 {
                    Text("\(habitStore.userProfile.completionsToNextLevel) completions to Level \(habitStore.userProfile.level + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Maximum level reached! 🎉")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            
            Divider()
            
            // Quick stats
            HStack(spacing: 0) {
                StatMiniView(
                    value: "\(habitStore.userProfile.totalCompletions)",
                    label: "Total Done",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .frame(height: 40)
                
                StatMiniView(
                    value: "\(habitStore.userProfile.currentStreak)",
                    label: "Current",
                    icon: "flame.fill",
                    color: .orange
                )
                
                Divider()
                    .frame(height: 40)
                
                StatMiniView(
                    value: "\(habitStore.userProfile.bestStreak)",
                    label: "Best",
                    icon: "trophy.fill",
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatMiniView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(value)
                    .font(.headline)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GamifiedStatsView()
        .environmentObject(HabitStore())
        .padding()
}
