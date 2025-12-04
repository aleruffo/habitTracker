//
//  RewardCardView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct RewardCardView: View {
    @EnvironmentObject private var habitStore: HabitStore
    let reward: Reward
    @State private var showingRedeemConfirmation = false
    
    private var linkedHabitName: String? {
        guard let habitId = reward.linkedHabitId else { return nil }
        return habitStore.habits.first { $0.id == habitId }?.name
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(reward.name)
                        .font(.headline)
                    
                    if !reward.description.isEmpty {
                        Text(reward.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Points badge
                VStack {
                    Text("\(reward.pointsEarned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(reward.isUnlocked ? .green : .primary)
                    Text("/ \(reward.pointsRequired)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.ProgressView(value: reward.progress)
                    .tint(reward.isUnlocked ? .green : .purple)
                
                HStack {
                    if let habitName = linkedHabitName {
                        Label(habitName, systemImage: "link")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(Int(reward.progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Action button
            if reward.isUnlocked {
                Button {
                    showingRedeemConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "gift.fill")
                        Text("Redeem Reward")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .alert("Redeem Reward?", isPresented: $showingRedeemConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Redeem") {
                        habitStore.redeemReward(reward)
                    }
                } message: {
                    Text("This will reset your progress for \"\(reward.name)\".")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(reward.isUnlocked ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    RewardCardView(reward: Reward(name: "Watch an Episode", description: "Unlock with 5 points", pointsRequired: 5, pointsEarned: 3))
        .environmentObject(HabitStore())
        .padding()
}
