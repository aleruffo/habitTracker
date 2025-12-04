//
//  TodayView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var showingProfile = false
    @State private var habitToEdit: Habit?
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private var completedCount: Int {
        habitStore.activeHabits.filter { $0.isCompleted(for: Date()) }.count
    }
    
    private var totalCount: Int {
        habitStore.activeHabits.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerView
                    
                    // Progress indicator
                    if totalCount > 0 {
                        todayProgressView
                    }
                    
                    // Habit Cards
                    VStack(spacing: 12) {
                        if habitStore.activeHabits.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(habitStore.activeHabits) { habit in
                                HabitCardView(habit: habit)
                                    .contextMenu {
                                        Button {
                                            habitToEdit = habit
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button {
                                            habitStore.archiveHabit(habit)
                                        } label: {
                                            Label("Archive", systemImage: "archivebox")
                                        }
                                        
                                        Button(role: .destructive) {
                                            habitStore.deleteHabit(habit)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
            .sheet(item: $habitToEdit) { habit in
                EditHabitView(habit: habit)
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(greeting), **\(habitStore.userProfile.name)**.")
                .font(.title)
            
            HStack(spacing: 4) {
                Text("🔥")
                Text("\(habitStore.userProfile.currentStreak) Day Streak")
                    .fontWeight(.semibold)
            }
            .font(.title3)
        }
        .padding(.horizontal)
    }
    
    private var todayProgressView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Progress")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            SwiftUI.ProgressView(value: Double(completedCount), total: Double(totalCount))
                .tint(completedCount == totalCount ? Color.green : Color.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 50))
                .foregroundStyle(.green)
            
            Text("Start Your Journey")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add your first habit to begin tracking your progress")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingAddHabit = true
            } label: {
                Text("Add Habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $name)
                        .onAppear {
                            name = habitStore.userProfile.name
                        }
                }
                
                Section("Statistics") {
                    LabeledContent("Total Completions", value: "\(habitStore.userProfile.totalCompletions)")
                    LabeledContent("Current Streak", value: "\(habitStore.userProfile.currentStreak) days")
                    LabeledContent("Best Streak", value: "\(habitStore.userProfile.bestStreak) days")
                    LabeledContent("Level", value: "\(habitStore.userProfile.level) - \(habitStore.userProfile.levelTitle)")
                    
                    if habitStore.userProfile.completionsToNextLevel > 0 {
                        LabeledContent("Next Level In", value: "\(habitStore.userProfile.completionsToNextLevel) completions")
                    }
                }
                
                Section("Data") {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Progress", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        habitStore.updateUserName(name)
                        dismiss()
                    }
                }
            }
            .alert("Reset Progress?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    habitStore.resetProgress()
                    dismiss()
                }
            } message: {
                Text("This will reset all your habit completions, streaks, and reward progress. This cannot be undone.")
            }
        }
    }
}

// MARK: - Edit Habit View

struct EditHabitView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    
    @State private var habitName: String = ""
    @State private var habitDescription: String = ""
    @State private var selectedIcon: String = "star.fill"
    
    private let icons = [
        "book.fill", "brain.head.profile", "pencil.line",
        "figure.run", "drop.fill", "leaf.fill",
        "moon.fill", "sun.max.fill", "heart.fill",
        "star.fill", "flame.fill", "bolt.fill"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit Name", text: $habitName)
                    TextField("Description", text: $habitDescription)
                }
                
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(icons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Statistics") {
                    LabeledContent("Total Completions", value: "\(habit.totalCompletions)")
                    LabeledContent("Current Streak", value: "\(habit.currentStreak) days")
                    LabeledContent("Weekly Rate", value: "\(Int(habit.weeklyCompletionRate * 100))%")
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedHabit = habit
                        updatedHabit.name = habitName
                        updatedHabit.description = habitDescription
                        updatedHabit.icon = selectedIcon
                        habitStore.updateHabit(updatedHabit)
                        dismiss()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
            .onAppear {
                habitName = habit.name
                habitDescription = habit.description
                selectedIcon = habit.icon
            }
        }
    }
}

#Preview {
    TodayView()
        .environmentObject(HabitStore())
}
