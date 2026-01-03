//
//  HabitStore.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Combine
import Foundation
import SwiftUI

/// Observable object that manages app data
final class HabitStore: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var rewards: [Reward] = []
    @Published var experiments: [Experiment] = []
    @Published var userProfile: UserProfile = UserProfile()
    @Published var habitScorecard: HabitScorecard = HabitScorecard()
    
    private let habitsKey = "SavedHabits"
    private let rewardsKey = "SavedRewards"
    private let profileKey = "SavedProfile"
    private let experimentsKey = "SavedExperiments"
    private let scorecardKey = "SavedScorecard"
    
    init() {
        loadData()
        if habits.isEmpty && rewards.isEmpty {
            loadSampleData()
        }
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveData()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveData()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        saveData()
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveData()
    }
    
    func toggleHabitCompletion(_ habit: Habit, for date: Date) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            let wasCompleted = habits[index].isCompleted(for: date)
            let wasInRecovery = habits[index].isInRecoveryMode
            
            habits[index].toggleCompletion(for: date)
            
            if !wasCompleted {
                userProfile.totalCompletions += 1
                addPointsToRewards(1)
                triggerHapticFeedback(.success)
                
                // Track "Never Miss Twice" recovery
                if wasInRecovery {
                    let dateString = Habit.dateFormatter.string(from: date)
                    habits[index].missedYesterdayRecovered.insert(dateString)
                    userProfile.neverMissTwiceRecoveries += 1
                }
                
                // Vote for linked identity statements
                voteForLinkedIdentities(habitId: habit.id)
            } else {
                userProfile.totalCompletions = max(0, userProfile.totalCompletions - 1)
                triggerHapticFeedback(.light)
            }
            
            updateStreak()
            saveData()
        }
    }
    
    /// Level up a habit's response (2-min rule progression)
    func levelUpHabitResponse(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if habits[index].response.currentLevel < 3 {
                habits[index].response.currentLevel += 1
                triggerHapticFeedback(.success)
                saveData()
            }
        }
    }
    
    func archiveHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isArchived = true
            saveData()
        }
    }
    
    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }
    
    var archivedHabits: [Habit] {
        habits.filter { $0.isArchived }
    }
    
    /// Habits currently in "Never Miss Twice" recovery mode
    var habitsInRecovery: [Habit] {
        activeHabits.filter { $0.isInRecoveryMode }
    }
    
    // MARK: - Reward Management
    
    func addReward(_ reward: Reward) {
        rewards.append(reward)
        saveData()
    }
    
    func updateReward(_ reward: Reward) {
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index] = reward
            saveData()
        }
    }
    
    func deleteReward(_ reward: Reward) {
        rewards.removeAll { $0.id == reward.id }
        saveData()
    }
    
    func addPointsToRewards(_ points: Int) {
        for index in rewards.indices {
            if !rewards[index].isUnlocked {
                rewards[index].pointsEarned += points
                if rewards[index].pointsEarned >= rewards[index].pointsRequired {
                    rewards[index].isUnlocked = true
                    triggerHapticFeedback(.success)
                }
            }
        }
    }
    
    func redeemReward(_ reward: Reward) {
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards[index].pointsEarned = 0
            rewards[index].isUnlocked = false
            triggerHapticFeedback(.medium)
        }
        saveData()
    }
    
    // MARK: - Experiment Management
    
    func addExperiment(_ experiment: Experiment) {
        experiments.append(experiment)
        saveData()
    }
    
    func startExperiment(_ experiment: Experiment) {
        if let index = experiments.firstIndex(where: { $0.id == experiment.id }) {
            experiments[index].isActive = true
            experiments[index].startDate = Date()
            triggerHapticFeedback(.medium)
            saveData()
        }
    }
    
    func endExperiment(_ experiment: Experiment) {
        if let index = experiments.firstIndex(where: { $0.id == experiment.id }) {
            experiments[index].isActive = false
            saveData()
        }
    }
    
    func deleteExperiment(_ experiment: Experiment) {
        experiments.removeAll { $0.id == experiment.id }
        saveData()
    }
    
    func addNoteToExperiment(_ experiment: Experiment, note: String) {
        if let index = experiments.firstIndex(where: { $0.id == experiment.id }) {
            let newNote = ExperimentNote(content: note)
            experiments[index].notes.append(newNote)
            saveData()
        }
    }
    
    var activeExperiments: [Experiment] {
        experiments.filter { $0.isActive }
    }
    
    // MARK: - Habit Scorecard Management
    
    func addScorecardBehavior(_ behavior: ScorecardBehavior) {
        habitScorecard.behaviors.append(behavior)
        saveData()
    }
    
    func updateScorecardBehavior(_ behavior: ScorecardBehavior) {
        if let index = habitScorecard.behaviors.firstIndex(where: { $0.id == behavior.id }) {
            habitScorecard.behaviors[index] = behavior
            saveData()
        }
    }
    
    func deleteScorecardBehavior(_ behavior: ScorecardBehavior) {
        habitScorecard.behaviors.removeAll { $0.id == behavior.id }
        saveData()
    }
    
    /// Convert a positive behavior from scorecard to a habit
    func convertBehaviorToHabit(_ behavior: ScorecardBehavior) -> Habit {
        var habit = Habit(
            name: behavior.behavior,
            icon: behavior.category.icon,
            habitType: .build
        )
        habit.cue = HabitCue(location: behavior.category.displayName)
        
        // Link the behavior to the new habit
        if let index = habitScorecard.behaviors.firstIndex(where: { $0.id == behavior.id }) {
            habitScorecard.behaviors[index].linkedHabitId = habit.id
        }
        
        return habit
    }
    
    // MARK: - Identity Management
    
    func addIdentityStatement(_ identity: IdentityStatement) {
        userProfile.identityStatements.append(identity)
        saveData()
    }
    
    func updateIdentityStatement(_ identity: IdentityStatement) {
        if let index = userProfile.identityStatements.firstIndex(where: { $0.id == identity.id }) {
            userProfile.identityStatements[index] = identity
            saveData()
        }
    }
    
    func deleteIdentityStatement(_ identity: IdentityStatement) {
        userProfile.identityStatements.removeAll { $0.id == identity.id }
        saveData()
    }
    
    /// Link a habit to an identity statement
    func linkHabitToIdentity(habitId: UUID, identityId: UUID) {
        if let index = userProfile.identityStatements.firstIndex(where: { $0.id == identityId }) {
            if !userProfile.identityStatements[index].linkedHabitIds.contains(habitId) {
                userProfile.identityStatements[index].linkedHabitIds.append(habitId)
                saveData()
            }
        }
    }
    
    /// Vote for all identity statements linked to a completed habit
    private func voteForLinkedIdentities(habitId: UUID) {
        for index in userProfile.identityStatements.indices {
            if userProfile.identityStatements[index].linkedHabitIds.contains(habitId) {
                userProfile.identityStatements[index].votesCount += 1
            }
        }
    }
    
    // MARK: - Profile Management
    
    func updateUserName(_ name: String) {
        userProfile.name = name
        saveData()
    }
    
    func resetProgress() {
        userProfile = UserProfile(name: userProfile.name)
        for index in habits.indices {
            habits[index].completedDates.removeAll()
        }
        for index in rewards.indices {
            rewards[index].pointsEarned = 0
            rewards[index].isUnlocked = false
        }
        saveData()
    }
    
    // MARK: - Streak Management
    
    private func updateStreak() {
        let allStreaks = habits.map { $0.currentStreak }
        userProfile.currentStreak = allStreaks.max() ?? 0
        userProfile.bestStreak = max(userProfile.bestStreak, userProfile.currentStreak)
    }
    
    /// Returns the overall completion percentage for today
    var todayCompletionRate: Double {
        let activeHabits = habits.filter { !$0.isArchived }
        guard !activeHabits.isEmpty else { return 0 }
        let completed = activeHabits.filter { $0.isCompleted(for: Date()) }.count
        return Double(completed) / Double(activeHabits.count)
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func triggerHapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    // MARK: - Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: habitsKey)
        }
        if let encoded = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(encoded, forKey: rewardsKey)
        }
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
        if let encoded = try? JSONEncoder().encode(experiments) {
            UserDefaults.standard.set(encoded, forKey: experimentsKey)
        }
        if let encoded = try? JSONEncoder().encode(habitScorecard) {
            UserDefaults.standard.set(encoded, forKey: scorecardKey)
        }
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: habitsKey),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
        if let data = UserDefaults.standard.data(forKey: rewardsKey),
           let decoded = try? JSONDecoder().decode([Reward].self, from: data) {
            rewards = decoded
        }
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
        if let data = UserDefaults.standard.data(forKey: experimentsKey),
           let decoded = try? JSONDecoder().decode([Experiment].self, from: data) {
            experiments = decoded
        }
        if let data = UserDefaults.standard.data(forKey: scorecardKey),
           let decoded = try? JSONDecoder().decode(HabitScorecard.self, from: data) {
            habitScorecard = decoded
        }
    }
    
    private func loadSampleData() {
        // Sample habits using the new Atomic Habits structure
        habits = [
            Habit(
                name: "Read",
                icon: "book.fill",
                habitType: .build,
                cue: HabitCue(time: Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date()),
                             location: "Living room",
                             currentHabit: "pour my morning coffee"),
                craving: HabitCraving(identityStatement: "a reader",
                                     motivation: "Readers are leaders. I want to learn something new every day.",
                                     temptationBundle: "I can enjoy my coffee while reading"),
                response: HabitResponse(twoMinuteVersion: "Read one page",
                                       fiveMinuteVersion: "Read for 5 minutes",
                                       tenMinuteVersion: "Read one chapter",
                                       fullVersion: "Read for 30 minutes",
                                       currentLevel: 0),
                reward: HabitReward(immediateReward: "Note one interesting idea",
                                   visualProgress: true,
                                   neverMissTwice: true)
            ),
            Habit(
                name: "Meditate",
                icon: "brain.head.profile",
                habitType: .build,
                cue: HabitCue(time: Calendar.current.date(bySettingHour: 6, minute: 30, second: 0, of: Date()),
                             location: "Bedroom",
                             currentHabit: "wake up"),
                craving: HabitCraving(identityStatement: "a calm and centered person",
                                     motivation: "I want to start each day with clarity and peace.",
                                     temptationBundle: ""),
                response: HabitResponse(twoMinuteVersion: "Take 3 deep breaths",
                                       fiveMinuteVersion: "5-minute guided meditation",
                                       tenMinuteVersion: "10-minute silent meditation",
                                       fullVersion: "20-minute meditation session",
                                       currentLevel: 0),
                reward: HabitReward(immediateReward: "Feel the calm wash over me",
                                   visualProgress: true,
                                   neverMissTwice: true),
                streakWarning: "Don't miss twice. Even 3 breaths counts."
            ),
            Habit(
                name: "Journal",
                icon: "pencil.line",
                habitType: .build,
                cue: HabitCue(time: Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date()),
                             location: "Desk",
                             currentHabit: "finish dinner"),
                craving: HabitCraving(identityStatement: "someone who reflects and grows",
                                     motivation: "Writing helps me process my thoughts and learn from each day.",
                                     temptationBundle: "I can light a candle and make it cozy"),
                response: HabitResponse(twoMinuteVersion: "Write one sentence",
                                       fiveMinuteVersion: "Write 3 things I'm grateful for",
                                       tenMinuteVersion: "Free write for 10 minutes",
                                       fullVersion: "Complete daily reflection template",
                                       currentLevel: 1),
                reward: HabitReward(immediateReward: "Read yesterday's entry",
                                   visualProgress: true,
                                   neverMissTwice: true)
            )
        ]
        
        rewards = [
            Reward(name: "Watch an Episode", description: "Unlock with 5 habit completions", pointsRequired: 5, pointsEarned: 0),
            Reward(name: "Listen to Podcast", description: "Unlock with 3 habit completions", pointsRequired: 3, pointsEarned: 0),
            Reward(name: "Social Media Scroll", description: "Unlock with 10 habit completions", pointsRequired: 10, pointsEarned: 0)
        ]
        
        experiments = [
            Experiment(name: "Morning Routine Stack", description: "Stack 3 habits: Wake → Meditate → Read → Coffee", durationDays: 7),
            Experiment(name: "Evening Wind-down", description: "No screens 1 hour before bed, replace with journaling", durationDays: 14)
        ]
        
        // Sample identity statements
        userProfile.identityStatements = [
            IdentityStatement(statement: "a reader who learns something new every day", 
                            category: .learning,
                            linkedHabitIds: [habits[0].id]),
            IdentityStatement(statement: "a calm and centered person",
                            category: .mindfulness,
                            linkedHabitIds: [habits[1].id])
        ]
        
        // Sample habit scorecard behaviors
        habitScorecard.behaviors = [
            ScorecardBehavior(behavior: "Check phone first thing in morning", rating: .negative, category: .morning),
            ScorecardBehavior(behavior: "Make the bed", rating: .positive, category: .morning),
            ScorecardBehavior(behavior: "Drink water after waking", rating: .positive, category: .morning),
            ScorecardBehavior(behavior: "Scroll social media before sleep", rating: .negative, category: .evening)
        ]
    }
}
