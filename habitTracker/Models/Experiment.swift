//
//  Experiment.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Represents a habit experiment - a time-boxed trial of a new habit or routine
struct Experiment: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var description: String
    var durationDays: Int
    var isActive: Bool
    var startDate: Date
    var linkedHabitIds: [UUID]
    var notes: [ExperimentNote]
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        durationDays: Int = 7,
        isActive: Bool = true,
        linkedHabitIds: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.durationDays = durationDays
        self.isActive = isActive
        self.startDate = Date()
        self.linkedHabitIds = linkedHabitIds
        self.notes = []
    }
    
    var daysRemaining: Int {
        guard isActive else { return 0 }
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: durationDays, to: startDate) ?? startDate
        let remaining = calendar.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, remaining)
    }
    
    var progress: Double {
        let calendar = Calendar.current
        let daysPassed = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(1.0, Double(daysPassed) / Double(durationDays))
    }
    
    var isCompleted: Bool {
        daysRemaining == 0 && progress >= 1.0
    }
    
    static func == (lhs: Experiment, rhs: Experiment) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

/// A note entry for an experiment
struct ExperimentNote: Identifiable, Codable, Hashable {
    let id: UUID
    var content: String
    var date: Date
    
    init(id: UUID = UUID(), content: String, date: Date = Date()) {
        self.id = id
        self.content = content
        self.date = date
    }
}
