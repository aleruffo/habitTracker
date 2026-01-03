//
//  HabitCardView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct HabitCardView: View {
    @EnvironmentObject private var habitStore: HabitStore
    let habit: Habit
    @State private var isExpanded = false
    @State private var showLevelUpConfirmation = false
    
    private var isCompleted: Bool {
        habit.isCompleted(for: Date())
    }
    
    private var hasWarning: Bool {
        (habit.streakWarning != nil || habit.isStreakAtRisk) && !isCompleted && habit.currentStreak > 0
    }
    
    private var isInRecovery: Bool {
        habit.isInRecoveryMode
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main habit row
            HStack(spacing: 14) {
                // Icon with streak indicator
                ZStack {
                    Image(systemName: habit.icon)
                        .font(.title2)
                        .foregroundStyle(isCompleted ? .green : .primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                    
                    // Streak badge
                    if habit.currentStreak > 0 {
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(4)
                            .background(isCompleted ? Color.green : (hasWarning ? Color.orange : Color.blue))
                            .clipShape(Circle())
                            .offset(x: 16, y: -16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.headline)
                        .strikethrough(isCompleted, color: .secondary)
                    
                    // Show current 2-minute rule level
                    HStack(spacing: 8) {
                        Text(habit.response.currentVersionName)
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        
                        if habit.currentStreak > 0 {
                            Label("\(habit.currentStreak)d", systemImage: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(hasWarning ? .orange : .secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        habitStore.toggleHabitCompletion(habit, for: Date())
                    }
                } label: {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(isCompleted ? .green : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }
            .padding()
            
            // Implementation Intention & Identity
            if !habit.cue.currentHabit.isEmpty || habit.identityStatement != nil {
                Divider()
                    .padding(.leading)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let identity = habit.identityStatement {
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundStyle(.purple)
                            Text(identity)
                                .font(.caption)
                                .foregroundStyle(.purple)
                        }
                    }
                    
                    if !habit.cue.currentHabit.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(habit.cue.habitStackingStatement ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            // 2-Minute Rule Progression
            Divider()
                .padding(.leading)
            
            Button {
                withAnimation(.spring(response: 0.3)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("2-Minute Rule Progression")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)
                                    .clipShape(Capsule())
                                
                                Rectangle()
                                    .fill(progressGradient)
                                    .frame(width: geometry.size.width * habit.response.progressPercentage, height: 6)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(height: 6)
                        
                        Text(habit.response.levelName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(spacing: 0) {
                    progressionLevel(level: 0, name: "Gateway", duration: "2 min", 
                                   description: habit.response.twoMinuteVersion, color: .green)
                    progressionLevel(level: 1, name: "Building", duration: "5 min",
                                   description: habit.response.fiveMinuteVersion, color: .blue)
                    progressionLevel(level: 2, name: "Growing", duration: "10 min",
                                   description: habit.response.tenMinuteVersion, color: .orange)
                    progressionLevel(level: 3, name: "Mastered", duration: "Full",
                                   description: habit.response.fullVersion, color: .purple)
                    
                    // Level up button
                    if habit.response.currentLevel < 3 && habit.currentStreak >= 7 {
                        Button {
                            showLevelUpConfirmation = true
                        } label: {
                            Label("Level Up", systemImage: "arrow.up.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                        .padding()
                    } else if habit.response.currentLevel < 3 {
                        Text("Complete 7 days at current level to unlock next")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .confirmationDialog("Level Up Habit?", isPresented: $showLevelUpConfirmation) {
                    Button("Level Up to \(nextLevelName)") {
                        habitStore.levelUpHabitResponse(habit)
                    }
                    Button("Stay at Current Level", role: .cancel) {}
                } message: {
                    Text("You've mastered \(habit.response.currentVersionName). Ready to take it to the next level?")
                }
            }
            
            // Never Miss Twice Warning
            if isInRecovery {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Never Miss Twice")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                        Text("You missed yesterday. Get back on track today!")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
            }
            // Streak warning
            else if hasWarning {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                    
                    Text(habit.streakWarning ?? "Complete today to keep your streak!")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.1))
            }
        }
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorderColor, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.green, .blue, .orange, .purple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var cardBackground: Color {
        if isInRecovery {
            return Color.blue.opacity(0.05)
        } else if hasWarning {
            return Color.orange.opacity(0.05)
        }
        return Color(.systemBackground)
    }
    
    private var cardBorderColor: Color {
        if isInRecovery {
            return Color.blue.opacity(0.3)
        } else if hasWarning {
            return Color.orange.opacity(0.3)
        }
        return Color.clear
    }
    
    private var nextLevelName: String {
        switch habit.response.currentLevel {
        case 0: return "Building (5 min)"
        case 1: return "Growing (10 min)"
        case 2: return "Mastered (Full)"
        default: return "Mastered"
        }
    }
    
    @ViewBuilder
    private func progressionLevel(level: Int, name: String, duration: String, description: String, color: Color) -> some View {
        let isCurrent = habit.response.currentLevel == level
        let isUnlocked = habit.response.currentLevel >= level
        
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : Color(.systemGray5))
                    .frame(width: 32, height: 32)
                
                if isUnlocked {
                    Image(systemName: isCurrent ? "checkmark.circle.fill" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .fontWeight(isCurrent ? .semibold : .regular)
                        .foregroundStyle(isUnlocked ? .primary : .secondary)
                    
                    Text("(\(duration))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color)
                            .clipShape(Capsule())
                    }
                }
                
                if !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isCurrent ? color.opacity(0.05) : Color.clear)
    }
}

#Preview {
    HabitCardView(habit: Habit(
        name: "Read",
        icon: "book.fill",
        cue: HabitCue(currentHabit: "pour my coffee"),
        craving: HabitCraving(identityStatement: "a reader"),
        response: HabitResponse(
            twoMinuteVersion: "Read one page",
            fiveMinuteVersion: "Read for 5 minutes",
            tenMinuteVersion: "Read one chapter",
            fullVersion: "Read for 30 minutes",
            currentLevel: 0
        )
    ))
    .environmentObject(HabitStore())
    .padding()
}
