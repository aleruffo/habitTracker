//
//  ProgressView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @State private var selectedMonth = Date()
    @State private var selectedDate: Date?
    
    private var completionRateForMonth: Double {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return 0
        }
        
        var completedDays = 0
        var totalDays = 0
        let today = calendar.startOfDay(for: Date())
        
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth),
                  date <= today else { continue }
            
            totalDays += 1
            let hasCompletion = habitStore.habits.contains { $0.isCompleted(for: date) }
            if hasCompletion {
                completedDays += 1
            }
        }
        
        return totalDays > 0 ? Double(completedDays) / Double(totalDays) : 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly summary card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(Int(completionRateForMonth * 100))% complete")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        SwiftUI.ProgressView(value: completionRateForMonth)
                            .tint(completionRateForMonth >= 0.8 ? .green : (completionRateForMonth >= 0.5 ? .orange : .red))
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Calendar
                    CalendarGridView(selectedMonth: $selectedMonth, selectedDate: $selectedDate)
                        .padding()
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Selected date details
                    if let date = selectedDate {
                        selectedDateView(for: date)
                    }
                    
                    // Stats
                    HStack(spacing: 0) {
                        StatItemView(
                            title: "Total\nCompletions",
                            value: "\(habitStore.userProfile.totalCompletions)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        Divider()
                            .frame(height: 60)
                        
                        StatItemView(
                            title: "Current\nStreak",
                            value: "\(habitStore.userProfile.currentStreak)",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        Divider()
                            .frame(height: 60)
                        
                        StatItemView(
                            title: "Best\nStreak",
                            value: "\(habitStore.userProfile.bestStreak)",
                            icon: "trophy.fill",
                            color: .yellow
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Gamified Stats
                    GamifiedStatsView()
                    
                    // Habit breakdown
                    if !habitStore.activeHabits.isEmpty {
                        habitBreakdownView
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }
    
    private func selectedDateView(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date.formatted(date: .complete, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    selectedDate = nil
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            let completedHabits = habitStore.habits.filter { $0.isCompleted(for: date) }
            
            if completedHabits.isEmpty {
                Text("No habits completed on this day")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(completedHabits) { habit in
                    HStack {
                        Image(systemName: habit.icon)
                            .foregroundStyle(.green)
                        Text(habit.name)
                            .font(.subheadline)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var habitBreakdownView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Breakdown")
                .font(.headline)
            
            ForEach(habitStore.activeHabits) { habit in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: habit.icon)
                            .foregroundStyle(.blue)
                        Text(habit.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(habit.weeklyCompletionRate * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(habit.weeklyCompletionRate >= 0.8 ? .green : (habit.weeklyCompletionRate >= 0.5 ? .orange : .red))
                    }
                    
                    SwiftUI.ProgressView(value: habit.weeklyCompletionRate)
                        .tint(habit.weeklyCompletionRate >= 0.8 ? .green : (habit.weeklyCompletionRate >= 0.5 ? .orange : .red))
                    
                    HStack {
                        Text("\(habit.currentStreak) day streak")
                        Spacer()
                        Text("\(habit.totalCompletions) total")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                
                if habit.id != habitStore.activeHabits.last?.id {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProgressView()
        .environmentObject(HabitStore())
}
