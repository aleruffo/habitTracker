//
//  UserProfile.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Level definitions with titles and required completions
struct Level {
    let number: Int
    let title: String
    let requiredCompletions: Int
    
    static let levels: [Level] = [
        Level(number: 1, title: "Beginner", requiredCompletions: 0),
        Level(number: 2, title: "Apprentice", requiredCompletions: 10),
        Level(number: 3, title: "Dedicated", requiredCompletions: 30),
        Level(number: 4, title: "Consistent Creator", requiredCompletions: 75),
        Level(number: 5, title: "Habit Master", requiredCompletions: 150),
        Level(number: 6, title: "Discipline Expert", requiredCompletions: 300),
        Level(number: 7, title: "Lifestyle Architect", requiredCompletions: 500),
        Level(number: 8, title: "Legend", requiredCompletions: 1000)
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

/// User profile data
struct UserProfile: Codable {
    var name: String
    var totalCompletions: Int
    var currentStreak: Int
    var bestStreak: Int
    
    init(
        name: String = "User",
        totalCompletions: Int = 0,
        currentStreak: Int = 0,
        bestStreak: Int = 0
    ) {
        self.name = name
        self.totalCompletions = totalCompletions
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
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
}
