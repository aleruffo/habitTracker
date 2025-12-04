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
    
    private var isCompleted: Bool {
        habit.isCompleted(for: Date())
    }
    
    private var hasWarning: Bool {
        (habit.streakWarning != nil || habit.isStreakAtRisk) && !isCompleted && habit.currentStreak > 0
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
                    
                    HStack(spacing: 8) {
                        if habit.currentStreak > 0 {
                            Label("\(habit.currentStreak)d", systemImage: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(hasWarning ? .orange : .secondary)
                        }
                        
                        if habit.totalCompletions > 0 {
                            Text("•")
                                .foregroundStyle(.secondary)
                            Text("\(Int(habit.weeklyCompletionRate * 100))% this week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
            
            // Sub-habits (expandable)
            if !habit.subHabits.isEmpty {
                Divider()
                    .padding(.leading)
                
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(habit.subHabits.count) sub-habits")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            if !isExpanded {
                                Text(habit.subHabits.map { $0.name }.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
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
                    ForEach(habit.subHabits) { subHabit in
                        HStack {
                            Text(subHabit.name)
                                .font(.subheadline)
                            
                            Spacer()
                            
                            if !subHabit.description.isEmpty {
                                Text(subHabit.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemBackground))
                    }
                }
            }
            
            // Streak warning
            if hasWarning {
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
        .background(hasWarning ? Color.orange.opacity(0.05) : Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(hasWarning ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HabitCardView(habit: Habit(name: "Read 10 pages", description: "After coffee"))
        .environmentObject(HabitStore())
        .padding()
}
