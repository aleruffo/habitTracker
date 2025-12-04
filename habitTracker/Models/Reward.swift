//
//  Reward.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Represents a reward in the temptation bundling system
struct Reward: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var pointsRequired: Int
    var pointsEarned: Int
    var isUnlocked: Bool
    var linkedHabitId: UUID?
    
    init(id: UUID = UUID(), name: String, description: String, pointsRequired: Int, pointsEarned: Int = 0, linkedHabitId: UUID? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.pointsRequired = pointsRequired
        self.pointsEarned = pointsEarned
        self.isUnlocked = pointsEarned >= pointsRequired
        self.linkedHabitId = linkedHabitId
    }
    
    var progress: Double {
        Double(pointsEarned) / Double(pointsRequired)
    }
}
