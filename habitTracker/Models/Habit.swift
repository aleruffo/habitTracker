//
//  Habit.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Represents a sub-habit or alternative version of a habit
struct SubHabit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    
    init(id: UUID = UUID(), name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

/// Represents a single habit with tracking capabilities
struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var icon: String
    var completedDates: Set<String>
    var createdAt: Date
    var subHabits: [SubHabit]
    var streakWarning: String?
    var reminderTime: Date?
    var isArchived: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        icon: String = "star.fill",
        subHabits: [SubHabit] = [],
        streakWarning: String? = nil,
        reminderTime: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.completedDates = []
        self.createdAt = Date()
        self.subHabits = subHabits
        self.streakWarning = streakWarning
        self.reminderTime = reminderTime
        self.isArchived = isArchived
    }
    
    func isCompleted(for date: Date) -> Bool {
        let dateString = Self.dateFormatter.string(from: date)
        return completedDates.contains(dateString)
    }
    
    mutating func toggleCompletion(for date: Date) {
        let dateString = Self.dateFormatter.string(from: date)
        if completedDates.contains(dateString) {
            completedDates.remove(dateString)
        } else {
            completedDates.insert(dateString)
        }
    }
    
    /// Calculates the current streak (consecutive days completed ending today or yesterday)
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Check if today is completed, if not start from yesterday
        if !isCompleted(for: checkDate) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        // Count consecutive days
        while isCompleted(for: checkDate) {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        return streak
    }
    
    /// Checks if the streak is at risk (missed yesterday but not today yet)
    var isStreakAtRisk: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        return !isCompleted(for: today) && !isCompleted(for: yesterday) && currentStreak == 0
    }
    
    /// Total number of completions
    var totalCompletions: Int {
        completedDates.count
    }
    
    /// Completion rate for the last 7 days
    var weeklyCompletionRate: Double {
        let calendar = Calendar.current
        var completedCount = 0
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()),
               isCompleted(for: date) {
                completedCount += 1
            }
        }
        
        return Double(completedCount) / 7.0
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
