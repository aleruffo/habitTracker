//
//  HabitScorecard.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 06/12/25.
//

import Foundation

/// Represents a behavior in the Habit Scorecard
/// From Atomic Habits: "The process of behavior change always starts with awareness"
struct ScorecardBehavior: Identifiable, Codable, Hashable {
    let id: UUID
    var behavior: String            // Description of the behavior
    var rating: BehaviorRating      // +, =, or -
    var category: BehaviorCategory  // Time of day or context
    var notes: String               // Optional reflection
    var linkedHabitId: UUID?        // If converted to a habit
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        behavior: String,
        rating: BehaviorRating = .neutral,
        category: BehaviorCategory = .morning,
        notes: String = "",
        linkedHabitId: UUID? = nil
    ) {
        self.id = id
        self.behavior = behavior
        self.rating = rating
        self.category = category
        self.notes = notes
        self.linkedHabitId = linkedHabitId
        self.createdAt = Date()
    }
}

/// Rating for behaviors: positive, neutral, or negative
enum BehaviorRating: String, Codable, CaseIterable {
    case positive = "positive"   // Good habit to build on
    case neutral = "neutral"     // Neither good nor bad
    case negative = "negative"   // Bad habit to break
    
    var symbol: String {
        switch self {
        case .positive: return "+"
        case .neutral: return "="
        case .negative: return "-"
        }
    }
    
    var displayName: String {
        switch self {
        case .positive: return "Positive"
        case .neutral: return "Neutral"
        case .negative: return "Negative"
        }
    }
    
    var color: String {
        switch self {
        case .positive: return "green"
        case .neutral: return "gray"
        case .negative: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .positive: return "plus.circle.fill"
        case .neutral: return "equal.circle.fill"
        case .negative: return "minus.circle.fill"
        }
    }
    
    var actionAdvice: String {
        switch self {
        case .positive: return "Keep and optimize this behavior"
        case .neutral: return "Consider if this serves your goals"
        case .negative: return "Apply the inversion of the 4 Laws"
        }
    }
}

/// Categories for organizing behaviors by time/context
enum BehaviorCategory: String, Codable, CaseIterable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case work = "work"
    case home = "home"
    case social = "social"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .work: return "Work"
        case .home: return "Home"
        case .social: return "Social"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        case .work: return "briefcase.fill"
        case .home: return "house.fill"
        case .social: return "person.2.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

/// The Habit Scorecard - a tool for awareness
/// "Until you make the unconscious conscious, it will direct your life and you will call it fate."
struct HabitScorecard: Codable {
    var behaviors: [ScorecardBehavior]
    var lastReviewDate: Date?
    
    init(behaviors: [ScorecardBehavior] = []) {
        self.behaviors = behaviors
        self.lastReviewDate = nil
    }
    
    /// Behaviors grouped by category
    var behaviorsByCategory: [BehaviorCategory: [ScorecardBehavior]] {
        Dictionary(grouping: behaviors, by: { $0.category })
    }
    
    /// Count of positive behaviors
    var positiveCount: Int {
        behaviors.filter { $0.rating == .positive }.count
    }
    
    /// Count of negative behaviors
    var negativeCount: Int {
        behaviors.filter { $0.rating == .negative }.count
    }
    
    /// Count of neutral behaviors
    var neutralCount: Int {
        behaviors.filter { $0.rating == .neutral }.count
    }
    
    /// Overall balance score (-100 to +100)
    var balanceScore: Int {
        guard !behaviors.isEmpty else { return 0 }
        let total = behaviors.count
        let score = (positiveCount - negativeCount) * 100 / total
        return score
    }
    
    /// Behaviors that should be converted to habits (positive ones not yet linked)
    var habitCandidates: [ScorecardBehavior] {
        behaviors.filter { $0.rating == .positive && $0.linkedHabitId == nil }
    }
    
    /// Behaviors that need the "inversion" treatment (negative ones)
    var breakingCandidates: [ScorecardBehavior] {
        behaviors.filter { $0.rating == .negative }
    }
}

/// Breaking Bad Habits: The Inversion of the 4 Laws
/// From Atomic Habits Chapter 13-16
struct BadHabitStrategy: Codable, Hashable {
    var makeItInvisible: String     // Law 1 Inversion: Remove cues
    var makeItUnattractive: String  // Law 2 Inversion: Reframe mindset
    var makeItDifficult: String     // Law 3 Inversion: Increase friction
    var makeItUnsatisfying: String  // Law 4 Inversion: Add immediate cost
    
    init(
        makeItInvisible: String = "",
        makeItUnattractive: String = "",
        makeItDifficult: String = "",
        makeItUnsatisfying: String = ""
    ) {
        self.makeItInvisible = makeItInvisible
        self.makeItUnattractive = makeItUnattractive
        self.makeItDifficult = makeItDifficult
        self.makeItUnsatisfying = makeItUnsatisfying
    }
}

/// Suggested daily behaviors for the scorecard
struct ScorecardSuggestions {
    static let commonMorningBehaviors = [
        "Check phone immediately after waking",
        "Make the bed",
        "Drink a glass of water",
        "Eat breakfast",
        "Exercise or stretch",
        "Meditate",
        "Review goals for the day",
        "Hit snooze button"
    ]
    
    static let commonAfternoonBehaviors = [
        "Take a lunch break",
        "Go for a walk",
        "Check social media",
        "Drink coffee/tea",
        "Snack between meals",
        "Take short breaks"
    ]
    
    static let commonEveningBehaviors = [
        "Prepare tomorrow's clothes",
        "Read before bed",
        "Watch TV",
        "Scroll through phone in bed",
        "Review the day",
        "Practice gratitude",
        "Eat late-night snacks"
    ]
}
