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
    
    private let habitsKey = "SavedHabits"
    private let rewardsKey = "SavedRewards"
    private let profileKey = "SavedProfile"
    private let experimentsKey = "SavedExperiments"
    
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
            habits[index].toggleCompletion(for: date)
            
            if !wasCompleted {
                userProfile.totalCompletions += 1
                addPointsToRewards(1)
                triggerHapticFeedback(.success)
            } else {
                userProfile.totalCompletions = max(0, userProfile.totalCompletions - 1)
                triggerHapticFeedback(.light)
            }
            
            updateStreak()
            saveData()
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
    }
    
    private func loadSampleData() {
        habits = [
            Habit(
                name: "Read 10 pages",
                description: "After pouring coffee.",
                icon: "book.fill"
            ),
            Habit(
                name: "Meditate 5 mins",
                description: "Before brushing teeth.",
                icon: "brain.head.profile",
                subHabits: [
                    SubHabit(name: "2-Minute Version:", description: "Too tired? Just 3 deep breaths.")
                ]
            ),
            Habit(
                name: "Journaling",
                description: "After dinner.",
                icon: "pencil.line",
                streakWarning: "Recover the streak. Don't miss twice."
            )
        ]
        
        rewards = [
            Reward(name: "Watch an Episode", description: "Unlock with 5 points", pointsRequired: 5, pointsEarned: 0),
            Reward(name: "Listen to Podcast", description: "Unlock with 3 points", pointsRequired: 3, pointsEarned: 0),
            Reward(name: "Social Media Scroll", description: "Unlock with 10 points", pointsRequired: 10, pointsEarned: 0)
        ]
        
        experiments = [
            Experiment(name: "Morning Routine Stack", description: "Try stacking 3 habits after waking up", durationDays: 7),
            Experiment(name: "Evening Wind-down", description: "No screens 1 hour before bed", durationDays: 14)
        ]
    }
}
