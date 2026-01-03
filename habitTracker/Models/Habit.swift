//
//  Habit.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

// MARK: - Atomic Habits: The Four Laws of Behavior Change

/// The type of habit - building good habits or breaking bad ones
enum HabitType: String, Codable, CaseIterable {
    case build = "build"    // Building a good habit
    case breakBad = "break" // Breaking a bad habit
    
    var displayName: String {
        switch self {
        case .build: return "Build"
        case .breakBad: return "Break"
        }
    }
}

/// Law 1: Make it Obvious (Cue) - The trigger that initiates the behavior
struct HabitCue: Codable, Hashable {
    var time: Date?              // When will you do it?
    var location: String         // Where will you do it?
    var currentHabit: String     // Habit stacking: "After I [CURRENT HABIT]..."
    
    init(time: Date? = nil, location: String = "", currentHabit: String = "") {
        self.time = time
        self.location = location
        self.currentHabit = currentHabit
    }
    
    /// Implementation intention statement
    var implementationIntention: String? {
        guard !location.isEmpty || time != nil else { return nil }
        var parts: [String] = []
        if let time = time {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            parts.append("at \(formatter.string(from: time))")
        }
        if !location.isEmpty {
            parts.append("in \(location)")
        }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
    
    /// Habit stacking statement
    var habitStackingStatement: String? {
        guard !currentHabit.isEmpty else { return nil }
        return "After I \(currentHabit)"
    }
}

/// Law 2: Make it Attractive (Craving) - The motivation and desire
struct HabitCraving: Codable, Hashable {
    var identityStatement: String    // "I am the type of person who..."
    var motivation: String           // Why this habit matters to you
    var temptationBundle: String     // Pair with something you enjoy
    
    init(identityStatement: String = "", motivation: String = "", temptationBundle: String = "") {
        self.identityStatement = identityStatement
        self.motivation = motivation
        self.temptationBundle = temptationBundle
    }
}

/// Law 3: Make it Easy (Response) - The 2-Minute Rule progression
struct HabitResponse: Codable, Hashable {
    var twoMinuteVersion: String     // The gateway habit (2 minutes or less)
    var fiveMinuteVersion: String    // Slightly expanded version
    var tenMinuteVersion: String     // More substantial version
    var fullVersion: String          // The ultimate goal behavior
    var currentLevel: Int            // 0=2min, 1=5min, 2=10min, 3=full
    
    init(
        twoMinuteVersion: String = "",
        fiveMinuteVersion: String = "",
        tenMinuteVersion: String = "",
        fullVersion: String = "",
        currentLevel: Int = 0
    ) {
        self.twoMinuteVersion = twoMinuteVersion
        self.fiveMinuteVersion = fiveMinuteVersion
        self.tenMinuteVersion = tenMinuteVersion
        self.fullVersion = fullVersion
        self.currentLevel = currentLevel
    }
    
    var currentVersionName: String {
        switch currentLevel {
        case 0: return twoMinuteVersion.isEmpty ? "2-minute version" : twoMinuteVersion
        case 1: return fiveMinuteVersion.isEmpty ? "5-minute version" : fiveMinuteVersion
        case 2: return tenMinuteVersion.isEmpty ? "10-minute version" : tenMinuteVersion
        default: return fullVersion.isEmpty ? "Full habit" : fullVersion
        }
    }
    
    var levelName: String {
        switch currentLevel {
        case 0: return "Gateway (2 min)"
        case 1: return "Building (5 min)"
        case 2: return "Growing (10 min)"
        default: return "Mastered"
        }
    }
    
    var progressPercentage: Double {
        Double(currentLevel) / 3.0
    }
}

/// Law 4: Make it Satisfying (Reward) - Immediate gratification
struct HabitReward: Codable, Hashable {
    var immediateReward: String      // What you get right after completing
    var visualProgress: Bool         // Track visually (habit tracker)
    var neverMissTwice: Bool         // Commitment to recover quickly
    
    init(immediateReward: String = "", visualProgress: Bool = true, neverMissTwice: Bool = true) {
        self.immediateReward = immediateReward
        self.visualProgress = visualProgress
        self.neverMissTwice = neverMissTwice
    }
}

/// Represents a sub-habit or alternative version of a habit (legacy support)
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

/// Represents a single habit built on Atomic Habits principles
struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var completedDates: Set<String>
    var createdAt: Date
    var isArchived: Bool
    
    // Atomic Habits: The Four Laws
    var habitType: HabitType
    var cue: HabitCue              // Law 1: Make it Obvious
    var craving: HabitCraving      // Law 2: Make it Attractive
    var response: HabitResponse    // Law 3: Make it Easy
    var reward: HabitReward        // Law 4: Make it Satisfying
    
    // Legacy support
    var description: String        // Kept for backward compatibility
    var subHabits: [SubHabit]      // Kept for backward compatibility
    var streakWarning: String?
    var reminderTime: Date?
    
    // Recovery tracking for "Never Miss Twice"
    var missedYesterdayRecovered: Set<String>  // Dates where we recovered from a miss
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String = "star.fill",
        habitType: HabitType = .build,
        cue: HabitCue = HabitCue(),
        craving: HabitCraving = HabitCraving(),
        response: HabitResponse = HabitResponse(),
        reward: HabitReward = HabitReward(),
        description: String = "",
        subHabits: [SubHabit] = [],
        streakWarning: String? = nil,
        reminderTime: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.habitType = habitType
        self.cue = cue
        self.craving = craving
        self.response = response
        self.reward = reward
        self.description = description
        self.completedDates = []
        self.createdAt = Date()
        self.subHabits = subHabits
        self.streakWarning = streakWarning
        self.reminderTime = reminderTime
        self.isArchived = isArchived
        self.missedYesterdayRecovered = []
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
    
    /// Checks if we're in a "Never Miss Twice" recovery situation
    var isInRecoveryMode: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        // We're in recovery if yesterday was missed but the day before was completed
        let dayBeforeYesterday = calendar.date(byAdding: .day, value: -2, to: today) ?? today
        return !isCompleted(for: yesterday) && isCompleted(for: dayBeforeYesterday) && !isCompleted(for: today)
    }
    
    /// Number of times we successfully recovered (never missed twice)
    var recoveryCount: Int {
        missedYesterdayRecovered.count
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
    
    /// The "1% Better" compound improvement - days since creation with completion rate
    var compoundGrowthDays: Int {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return max(1, daysSinceCreation)
    }
    
    /// Theoretical compound improvement (1.01^days)
    var compoundGrowthMultiplier: Double {
        pow(1.01, Double(compoundGrowthDays))
    }
    
    /// Full implementation intention statement
    var implementationIntentionStatement: String {
        var statement = "I will \(response.currentVersionName)"
        if let cueStatement = cue.implementationIntention {
            statement += " \(cueStatement)"
        }
        if let stackStatement = cue.habitStackingStatement {
            statement = "\(stackStatement), \(statement.lowercased())"
        }
        return statement
    }
    
    /// Identity statement for this habit
    var identityStatement: String? {
        guard !craving.identityStatement.isEmpty else { return nil }
        return "I am \(craving.identityStatement)"
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
