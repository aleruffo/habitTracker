//
//  LabView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct LabView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @State private var showingAddReward = false
    @State private var showingAddExperiment = false
    @State private var selectedExperiment: Experiment?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Temptation Bundling Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Temptation Bundling")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                showingAddReward = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                        }
                        
                        Text("Link rewards to habits to build motivation")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if habitStore.rewards.isEmpty {
                            emptyRewardsView
                        } else {
                            ForEach(habitStore.rewards) { reward in
                                RewardCardView(reward: reward)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            habitStore.deleteReward(reward)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Habit Experiments Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Habit Experiments")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                showingAddExperiment = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                        }
                        
                        Text("Try new habits for a set period before committing")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if habitStore.experiments.isEmpty {
                            emptyExperimentsView
                        } else {
                            ForEach(habitStore.experiments) { experiment in
                                ExperimentCardView(experiment: experiment)
                                    .onTapGesture {
                                        selectedExperiment = experiment
                                    }
                                    .contextMenu {
                                        if !experiment.isCompleted {
                                            Button {
                                                habitStore.endExperiment(experiment)
                                            } label: {
                                                Label("End Early", systemImage: "stop.circle")
                                            }
                                        }
                                        
                                        Button(role: .destructive) {
                                            habitStore.deleteExperiment(experiment)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habit Lab")
            .sheet(isPresented: $showingAddReward) {
                AddRewardView()
            }
            .sheet(isPresented: $showingAddExperiment) {
                AddExperimentView()
            }
            .sheet(item: $selectedExperiment) { experiment in
                ExperimentDetailView(experiment: experiment)
            }
        }
    }
    
    private var emptyRewardsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "gift.fill")
                .font(.largeTitle)
                .foregroundStyle(.purple)
            
            Text("No rewards yet")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("Add rewards to motivate yourself")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyExperimentsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "flask.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            
            Text("No experiments yet")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("Start a time-boxed experiment to try new habits")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Experiment Card View

struct ExperimentCardView: View {
    let experiment: Experiment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(experiment.name)
                        .font(.headline)
                    
                    if !experiment.description.isEmpty {
                        Text(experiment.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if experiment.isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else if experiment.isActive {
                    Text("\(experiment.daysRemaining)d left")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                SwiftUI.ProgressView(value: experiment.progress)
                    .tint(experiment.isCompleted ? .green : .blue)
                
                HStack {
                    Text("Started \(experiment.startDate.formatted(date: .abbreviated, time: .omitted))")
                    Spacer()
                    Text("\(Int(experiment.progress * 100))% complete")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Reward View

struct AddRewardView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var rewardName = ""
    @State private var rewardDescription = ""
    @State private var pointsRequired = 10
    @State private var selectedHabitId: UUID?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reward Details") {
                    TextField("Reward Name", text: $rewardName)
                    TextField("Description (optional)", text: $rewardDescription)
                }
                
                Section("Points Required") {
                    Stepper("\(pointsRequired) points", value: $pointsRequired, in: 1...100)
                    
                    Text("Earn 1 point each time you complete the linked habit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Link to Habit (Optional)") {
                    Picker("Habit", selection: $selectedHabitId) {
                        Text("None").tag(nil as UUID?)
                        ForEach(habitStore.activeHabits) { habit in
                            Text(habit.name).tag(habit.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Add Reward")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let reward = Reward(
                            name: rewardName,
                            description: rewardDescription,
                            pointsRequired: pointsRequired,
                            linkedHabitId: selectedHabitId
                        )
                        habitStore.addReward(reward)
                        dismiss()
                    }
                    .disabled(rewardName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Add Experiment View

struct AddExperimentView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var experimentName = ""
    @State private var experimentDescription = ""
    @State private var durationDays = 7
    
    private let durations = [7, 14, 21, 30]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Experiment Details") {
                    TextField("What are you trying?", text: $experimentName)
                    TextField("Description (optional)", text: $experimentDescription)
                }
                
                Section("Duration") {
                    Picker("Duration", selection: $durationDays) {
                        ForEach(durations, id: \.self) { days in
                            Text("\(days) days").tag(days)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Short experiments help you test new habits without overcommitting")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Experiment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        let experiment = Experiment(
                            name: experimentName,
                            description: experimentDescription,
                            durationDays: durationDays
                        )
                        habitStore.addExperiment(experiment)
                        dismiss()
                    }
                    .disabled(experimentName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Experiment Detail View

struct ExperimentDetailView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    let experiment: Experiment
    @State private var newNote = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Status card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(experiment.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            statusBadge
                        }
                        
                        if !experiment.description.isEmpty {
                            Text(experiment.description)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                        
                        // Progress
                        VStack(alignment: .leading, spacing: 8) {
                            SwiftUI.ProgressView(value: experiment.progress)
                                .tint(experiment.isCompleted ? .green : .blue)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Day \(experiment.durationDays - experiment.daysRemaining) of \(experiment.durationDays)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Started \(experiment.startDate.formatted(date: .long, time: .omitted))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(Int(experiment.progress * 100))%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundStyle(experiment.isCompleted ? .green : .blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                        
                        HStack {
                            TextField("Add a note...", text: $newNote)
                                .textFieldStyle(.roundedBorder)
                            
                            Button {
                                if !newNote.isEmpty {
                                    habitStore.addNoteToExperiment(experiment, note: newNote)
                                    newNote = ""
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(newNote.isEmpty)
                        }
                        
                        if experiment.notes.isEmpty {
                            Text("No notes yet. Add notes to track your progress and reflections.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(experiment.notes) { note in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.content)
                                        .font(.subheadline)
                                    
                                    Text(note.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Actions
                    if !experiment.isCompleted {
                        Button(role: .destructive) {
                            habitStore.endExperiment(experiment)
                            dismiss()
                        } label: {
                            Text("End Experiment Early")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Experiment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var statusBadge: some View {
        Group {
            if experiment.isCompleted {
                Text("Completed")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            } else if experiment.isActive {
                Text("\(experiment.daysRemaining) days left")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    LabView()
        .environmentObject(HabitStore())
}
