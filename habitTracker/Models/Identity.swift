//
//  Identity.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 06/12/25.
//

import Foundation

/// Represents an identity statement - the core of identity-based habits
/// "Every action is a vote for the type of person you wish to become"
struct IdentityStatement: Identifiable, Codable, Hashable {
    let id: UUID
    var statement: String           // "I am the type of person who..."
    var category: IdentityCategory
    var linkedHabitIds: [UUID]      // Habits that reinforce this identity
    var votesCount: Int             // Number of times reinforced through habit completion
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        statement: String,
        category: IdentityCategory = .health,
        linkedHabitIds: [UUID] = [],
        votesCount: Int = 0
    ) {
        self.id = id
        self.statement = statement
        self.category = category
        self.linkedHabitIds = linkedHabitIds
        self.votesCount = votesCount
        self.createdAt = Date()
    }
    
    /// Full identity statement
    var fullStatement: String {
        "I am \(statement)"
    }
    
    /// Strength of identity based on votes (habit completions)
    var identityStrength: IdentityStrength {
        switch votesCount {
        case 0..<5: return .emerging
        case 5..<20: return .developing
        case 20..<50: return .established
        case 50..<100: return .strong
        default: return .coreIdentity
        }
    }
}

/// Categories for identity statements
enum IdentityCategory: String, Codable, CaseIterable {
    case health = "health"
    case fitness = "fitness"
    case learning = "learning"
    case creativity = "creativity"
    case productivity = "productivity"
    case relationships = "relationships"
    case mindfulness = "mindfulness"
    case finance = "finance"
    case career = "career"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .health: return "Health"
        case .fitness: return "Fitness"
        case .learning: return "Learning"
        case .creativity: return "Creativity"
        case .productivity: return "Productivity"
        case .relationships: return "Relationships"
        case .mindfulness: return "Mindfulness"
        case .finance: return "Finance"
        case .career: return "Career"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .learning: return "book.fill"
        case .creativity: return "paintbrush.fill"
        case .productivity: return "checkmark.circle.fill"
        case .relationships: return "person.2.fill"
        case .mindfulness: return "brain.head.profile"
        case .finance: return "dollarsign.circle.fill"
        case .career: return "briefcase.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: String {
        switch self {
        case .health: return "red"
        case .fitness: return "orange"
        case .learning: return "blue"
        case .creativity: return "purple"
        case .productivity: return "green"
        case .relationships: return "pink"
        case .mindfulness: return "teal"
        case .finance: return "yellow"
        case .career: return "indigo"
        case .other: return "gray"
        }
    }
}

/// Strength levels for identity based on reinforcement
enum IdentityStrength: String, Codable {
    case emerging = "Emerging"
    case developing = "Developing"
    case established = "Established"
    case strong = "Strong"
    case coreIdentity = "Core Identity"
    
    var description: String {
        switch self {
        case .emerging: return "Just starting to form"
        case .developing: return "Building momentum"
        case .established: return "Becoming natural"
        case .strong: return "Deeply ingrained"
        case .coreIdentity: return "Part of who you are"
        }
    }
    
    var progress: Double {
        switch self {
        case .emerging: return 0.1
        case .developing: return 0.3
        case .established: return 0.5
        case .strong: return 0.75
        case .coreIdentity: return 1.0
        }
    }
}

/// Suggested identity statements for different categories
struct IdentitySuggestions {
    static let suggestions: [IdentityCategory: [String]] = [
        .health: [
            "someone who prioritizes their health",
            "a person who nourishes their body well",
            "someone who gets enough sleep",
            "a person who stays hydrated"
        ],
        .fitness: [
            "an athlete",
            "someone who moves their body daily",
            "a runner",
            "someone who never misses a workout"
        ],
        .learning: [
            "a lifelong learner",
            "someone who reads every day",
            "a curious person who asks questions",
            "someone who embraces challenges"
        ],
        .creativity: [
            "a creative person",
            "an artist",
            "a writer",
            "someone who creates something every day"
        ],
        .productivity: [
            "someone who finishes what they start",
            "an organized person",
            "someone who respects their time",
            "a person who plans their day"
        ],
        .relationships: [
            "a great friend",
            "someone who stays in touch",
            "a person who listens well",
            "someone who shows up for others"
        ],
        .mindfulness: [
            "a calm and centered person",
            "someone who meditates daily",
            "a person who responds rather than reacts",
            "someone who practices gratitude"
        ],
        .finance: [
            "someone who saves money",
            "a financially responsible person",
            "someone who invests in their future",
            "a person who lives within their means"
        ],
        .career: [
            "a professional who delivers quality work",
            "someone who constantly improves",
            "a leader in my field",
            "someone who helps others succeed"
        ],
        .other: [
            "the best version of myself",
            "someone who keeps their promises",
            "a person of integrity"
        ]
    ]
    
    static func getSuggestions(for category: IdentityCategory) -> [String] {
        suggestions[category] ?? suggestions[.other]!
    }
}
