//
//  UserProfile.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Level definitions with titles and required completions
/// Based on Atomic Habits: Small improvements compound over time
struct Level {
    let number: Int
    let title: String
    let requiredCompletions: Int
    let atomicHabitsQuote: String  // Inspirational quote from the book
    
    static let levels: [Level] = [
        Level(number: 1, title: "Beginner", requiredCompletions: 0,
              atomicHabitsQuote: "Every action is a vote for the type of person you wish to become."),
        Level(number: 2, title: "Apprentice", requiredCompletions: 10,
              atomicHabitsQuote: "You do not rise to the level of your goals. You fall to the level of your systems."),
        Level(number: 3, title: "Dedicated", requiredCompletions: 30,
              atomicHabitsQuote: "Habits are the compound interest of self-improvement."),
        Level(number: 4, title: "Consistent Creator", requiredCompletions: 75,
              atomicHabitsQuote: "The most effective way to change your habits is to focus on who you wish to become."),
        Level(number: 5, title: "Habit Master", requiredCompletions: 150,
              atomicHabitsQuote: "Success is the product of daily habits—not once-in-a-lifetime transformations."),
        Level(number: 6, title: "Discipline Expert", requiredCompletions: 300,
              atomicHabitsQuote: "You should be far more concerned with your current trajectory than with your current results."),
        Level(number: 7, title: "Lifestyle Architect", requiredCompletions: 500,
              atomicHabitsQuote: "Environment is the invisible hand that shapes human behavior."),
        Level(number: 8, title: "Legend", requiredCompletions: 1000,
              atomicHabitsQuote: "The ultimate form of intrinsic motivation is when a habit becomes part of your identity.")
    ]
    
    static func current(for completions: Int) -> Level {
        var currentLevel = levels[0]
        for level in levels {
            if completions >= level.requiredCompletions {
                currentLevel = level
            } else {
                break
            }
        }
        return currentLevel
    }
    
    static func progress(for completions: Int) -> Double {
        let current = current(for: completions)
        guard let nextIndex = levels.firstIndex(where: { $0.number == current.number + 1 }) else {
            return 1.0 // Max level reached
        }
        let next = levels[nextIndex]
        let progressInLevel = completions - current.requiredCompletions
        let levelRange = next.requiredCompletions - current.requiredCompletions
        return Double(progressInLevel) / Double(levelRange)
    }
}

/// User profile data with identity-based tracking
struct UserProfile: Codable {
    var name: String
    var totalCompletions: Int
    var currentStreak: Int
    var bestStreak: Int
    
    // Atomic Habits: Identity-based metrics
    var identityStatements: [IdentityStatement]
    var neverMissTwiceRecoveries: Int      // Times recovered from a miss
    var longestNeverMissTwiceStreak: Int   // Longest streak without missing twice
    
    // 1% Better tracking
    var daysSinceStart: Int
    var compoundGrowthPercentage: Double {
        // 1% better every day compounds to 37x better in a year
        pow(1.01, Double(daysSinceStart))
    }
    
    init(
        name: String = "User",
        totalCompletions: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        identityStatements: [IdentityStatement] = [],
        neverMissTwiceRecoveries: Int = 0,
        longestNeverMissTwiceStreak: Int = 0,
        daysSinceStart: Int = 0
    ) {
        self.name = name
        self.totalCompletions = totalCompletions
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.identityStatements = identityStatements
        self.neverMissTwiceRecoveries = neverMissTwiceRecoveries
        self.longestNeverMissTwiceStreak = longestNeverMissTwiceStreak
        self.daysSinceStart = daysSinceStart
    }
    
    var level: Int {
        Level.current(for: totalCompletions).number
    }
    
    var levelTitle: String {
        Level.current(for: totalCompletions).title
    }
    
    var levelProgress: Double {
        Level.progress(for: totalCompletions)
    }
    
    var completionsToNextLevel: Int {
        let current = Level.current(for: totalCompletions)
        guard let nextIndex = Level.levels.firstIndex(where: { $0.number == current.number + 1 }) else {
            return 0
        }
        return Level.levels[nextIndex].requiredCompletions - totalCompletions
    }
    
    /// Current inspirational quote based on level
    var currentQuote: String {
        Level.current(for: totalCompletions).atomicHabitsQuote
    }
    
    /// Primary identity statement (most reinforced)
    var primaryIdentity: IdentityStatement? {
        identityStatements.max(by: { $0.votesCount < $1.votesCount })
    }
    
    /// Add a vote to an identity statement when completing a linked habit
    mutating func voteForIdentity(_ identityId: UUID) {
        if let index = identityStatements.firstIndex(where: { $0.id == identityId }) {
            identityStatements[index].votesCount += 1
        }
    }
    
    /// Calculate the "1% better" compound effect message
    var compoundGrowthMessage: String {
        let multiplier = compoundGrowthPercentage
        if multiplier < 2 {
            return String(format: "%.0f%% improved", (multiplier - 1) * 100)
        } else {
            return String(format: "%.1fx better than day 1", multiplier)
        }
    }
}

