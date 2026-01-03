//
//  GamifiedStatsView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct JourneyView: View {
    @EnvironmentObject private var habitStore: HabitStore
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Atomic Habits Quote
                    quoteCard
                    
                    // Level Progress
                    levelProgressCard
                    
                    // 1% Better Compound Growth
                    compoundGrowthCard
                    
                    // Never Miss Twice Recovery Stats
                    if habitStore.userProfile.neverMissTwiceRecoveries > 0 {
                        neverMissTwiceCard
                    }
                    
                    // Identity Progress
                    if !habitStore.userProfile.identityStatements.isEmpty {
                        identityProgressView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Journey")
        }
    }
    
    // MARK: - Level Progress
    
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
    
    private var levelProgressCard: some View {
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
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Atomic Habits Quote Card
    
    private var quoteCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text(habitStore.userProfile.currentQuote)
                .font(.subheadline)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
            
            Text("— Atomic Habits")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 1% Better Compound Growth
    
    private var compoundGrowthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                Text("The Power of 1% Better")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("Small habits compound over time. 1% better every day = 37x better in a year.")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(habitStore.userProfile.daysSinceStart)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text(habitStore.userProfile.compoundGrowthMessage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("Compound Growth")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Visual representation
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: min(habitStore.userProfile.compoundGrowthPercentage / 37, 1))
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("1%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Never Miss Twice Card
    
    private var neverMissTwiceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                Text("Never Miss Twice")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("\"The first mistake is never the one that ruins you. It's the spiral of repeated mistakes.\"")
                .font(.caption)
                .italic()
                .foregroundStyle(.secondary)
            
            HStack(spacing: 20) {
                VStack {
                    Text("\(habitStore.userProfile.neverMissTwiceRecoveries)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("Recoveries")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Recovery badges
                if habitStore.userProfile.neverMissTwiceRecoveries >= 10 {
                    recoveryBadge(count: 10, title: "Resilient", color: .bronze)
                }
                if habitStore.userProfile.neverMissTwiceRecoveries >= 25 {
                    recoveryBadge(count: 25, title: "Persistent", color: .silver)
                }
                if habitStore.userProfile.neverMissTwiceRecoveries >= 50 {
                    recoveryBadge(count: 50, title: "Unstoppable", color: .gold)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func recoveryBadge(count: Int, title: String, color: BadgeColor) -> some View {
        VStack(spacing: 4) {
            Image(systemName: "medal.fill")
                .font(.title2)
                .foregroundStyle(color.color)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private enum BadgeColor {
        case bronze, silver, gold
        
        var color: Color {
            switch self {
            case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
            case .silver: return Color(red: 0.75, green: 0.75, blue: 0.75)
            case .gold: return Color(red: 1, green: 0.84, blue: 0)
            }
        }
    }
    
    // MARK: - Identity Progress
    
    private var identityProgressView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.fill.checkmark")
                    .font(.title2)
                    .foregroundStyle(.purple)
                
                Text("Identity Progress")
                    .font(.headline)
                
                Spacer()
            }
            
            Text("\"Every action is a vote for the type of person you wish to become.\"")
                .font(.caption)
                .italic()
                .foregroundStyle(.secondary)
            
            ForEach(habitStore.userProfile.identityStatements) { identity in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(identity.fullStatement)
                            .font(.subheadline)
                        Spacer()
                        Text("\(identity.votesCount) votes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    SwiftUI.ProgressView(value: identity.identityStrength.progress)
                        .tint(.purple)
                    
                    Text(identity.identityStrength.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    JourneyView()
        .environmentObject(HabitStore())
}
