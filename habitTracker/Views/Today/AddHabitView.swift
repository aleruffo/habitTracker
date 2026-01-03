//
//  AddHabitView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    // Basic info
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var habitType: HabitType = .build
    
    // Law 1: Make it Obvious (Cue)
    @State private var cueTime: Date = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var useTime = false
    @State private var cueLocation = ""
    @State private var currentHabit = ""  // Habit stacking
    
    // Law 2: Make it Attractive (Craving)
    @State private var identityStatement = ""
    @State private var motivation = ""
    @State private var temptationBundle = ""
    
    // Law 3: Make it Easy (Response) - 2-Minute Rule
    @State private var twoMinuteVersion = ""
    @State private var fiveMinuteVersion = ""
    @State private var tenMinuteVersion = ""
    @State private var fullVersion = ""
    
    // Law 4: Make it Satisfying (Reward)
    @State private var immediateReward = ""
    @State private var neverMissTwice = true
    
    // UI State
    @State private var currentStep = 0
    
    private let icons = [
        "book.fill", "brain.head.profile", "pencil.line",
        "figure.run", "drop.fill", "leaf.fill",
        "moon.fill", "sun.max.fill", "heart.fill",
        "star.fill", "flame.fill", "bolt.fill",
        "cup.and.saucer.fill", "fork.knife", "bed.double.fill",
        "music.note", "paintbrush.fill", "gamecontroller.fill"
    ]
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentStep) {
                // Step 1: Basic Info & Identity
                basicInfoStep
                    .tag(0)
                
                // Step 2: Cue (Law 1)
                cueStep
                    .tag(1)
                
                // Step 3: Response - 2 Minute Rule (Law 3)
                responseStep
                    .tag(2)
                
                // Step 4: Reward (Law 4)
                rewardStep
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if currentStep < 3 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .disabled(currentStep == 0 && habitName.isEmpty)
                    } else {
                        Button("Create") {
                            createHabit()
                        }
                        .disabled(habitName.isEmpty)
                    }
                }
            }
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Who Do You Want to Be?"
        case 1: return "Make it Obvious"
        case 2: return "Make it Easy"
        case 3: return "Make it Satisfying"
        default: return "New Habit"
        }
    }
    
    // MARK: - Step 1: Basic Info & Identity
    
    private var basicInfoStep: some View {
        Form {
            Section {
                Text("\"Every action is a vote for the type of person you wish to become.\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section("What habit do you want to build?") {
                TextField("e.g., Read, Meditate, Exercise", text: $habitName)
                
                Picker("Type", selection: $habitType) {
                    ForEach(HabitType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
            }
            
            Section("Who is the type of person that does this?") {
                HStack {
                    Text("I am")
                        .foregroundStyle(.secondary)
                    TextField("a reader, an athlete...", text: $identityStatement)
                }
                
                TextField("Why does this matter to you?", text: $motivation, axis: .vertical)
                    .lineLimit(2...4)
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
        }
    }
    
    // MARK: - Step 2: Cue (Law 1 - Make it Obvious)
    
    private var cueStep: some View {
        Form {
            Section {
                Text("\"The two most common cues are time and location. Implementation intentions leverage both.\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section("When and where will you do this?") {
                Toggle("Set a specific time", isOn: $useTime)
                
                if useTime {
                    DatePicker("Time", selection: $cueTime, displayedComponents: .hourAndMinute)
                }
                
                TextField("Location (e.g., living room, office)", text: $cueLocation)
            }
            
            Section {
                HStack {
                    Text("After I")
                        .foregroundStyle(.secondary)
                    TextField("pour my coffee, wake up...", text: $currentHabit)
                }
            } header: {
                Text("Habit Stacking")
            } footer: {
                Text("Link this new habit to an existing one. \"After I [CURRENT HABIT], I will [NEW HABIT].\"")
            }
            
            if !implementationIntentionPreview.isEmpty {
                Section("Your Implementation Intention") {
                    Text(implementationIntentionPreview)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var implementationIntentionPreview: String {
        var parts: [String] = []
        
        if !currentHabit.isEmpty {
            parts.append("After I \(currentHabit),")
        }
        
        if habitName.isEmpty {
            parts.append("I will [habit]")
        } else {
            parts.append("I will \(habitName.lowercased())")
        }
        
        if useTime {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            parts.append("at \(formatter.string(from: cueTime))")
        }
        
        if !cueLocation.isEmpty {
            parts.append("in \(cueLocation)")
        }
        
        return parts.joined(separator: " ") + "."
    }
    
    // MARK: - Step 3: Response (Law 3 - Make it Easy)
    
    private var responseStep: some View {
        Form {
            Section {
                Text("\"A habit must be established before it can be improved. Master the art of showing up.\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Gateway (2 min)", systemImage: "1.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                    TextField("e.g., Read one page", text: $twoMinuteVersion)
                    Text("This is your \"showing up\" version. You'll start here!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("The 2-Minute Rule")
            } footer: {
                Text("Scale your habit down to 2 minutes or less. Make it so easy you can't say no.")
            }
            
            Section("Progression Levels") {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Building (5 min)", systemImage: "2.circle")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    TextField("e.g., Read for 5 minutes", text: $fiveMinuteVersion)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Growing (10 min)", systemImage: "3.circle")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    TextField("e.g., Read one chapter", text: $tenMinuteVersion)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("Mastered (Full)", systemImage: "4.circle")
                        .font(.subheadline)
                        .foregroundStyle(.purple)
                    TextField("e.g., Read for 30 minutes", text: $fullVersion)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Step 4: Reward (Law 4 - Make it Satisfying)
    
    private var rewardStep: some View {
        Form {
            Section {
                Text("\"What is immediately rewarded is repeated. What is immediately punished is avoided.\"")
                    .font(.subheadline)
                    .italic()
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            }
            
            Section("Immediate Reward") {
                TextField("What will you enjoy after completing?", text: $immediateReward)
                Text("Give yourself something to look forward to right after.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                TextField("Pair with something you enjoy", text: $temptationBundle)
            } header: {
                Text("Temptation Bundling (Optional)")
            } footer: {
                Text("\"After I [HABIT I NEED], I will [HABIT I WANT].\" Link this habit with something you enjoy.")
            }
            
            Section {
                Toggle("Never Miss Twice", isOn: $neverMissTwice)
            } header: {
                Text("Commitment")
            } footer: {
                Text("\"The first mistake is never the one that ruins you. It's the spiral of repeated mistakes that follows.\"")
            }
            
            // Preview section
            Section("Your Habit Summary") {
                VStack(alignment: .leading, spacing: 8) {
                    if !identityStatement.isEmpty {
                        Label("I am \(identityStatement)", systemImage: "person.fill")
                            .font(.subheadline)
                    }
                    
                    Text(implementationIntentionPreview)
                        .font(.subheadline)
                    
                    if !twoMinuteVersion.isEmpty {
                        Label("Start with: \(twoMinuteVersion)", systemImage: "leaf.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    // MARK: - Create Habit
    
    private func createHabit() {
        let cue = HabitCue(
            time: useTime ? cueTime : nil,
            location: cueLocation,
            currentHabit: currentHabit
        )
        
        let craving = HabitCraving(
            identityStatement: identityStatement,
            motivation: motivation,
            temptationBundle: temptationBundle
        )
        
        let response = HabitResponse(
            twoMinuteVersion: twoMinuteVersion.isEmpty ? habitName : twoMinuteVersion,
            fiveMinuteVersion: fiveMinuteVersion,
            tenMinuteVersion: tenMinuteVersion,
            fullVersion: fullVersion.isEmpty ? habitName : fullVersion,
            currentLevel: 0
        )
        
        let reward = HabitReward(
            immediateReward: immediateReward,
            visualProgress: true,
            neverMissTwice: neverMissTwice
        )
        
        let habit = Habit(
            name: habitName,
            icon: selectedIcon,
            habitType: habitType,
            cue: cue,
            craving: craving,
            response: response,
            reward: reward
        )
        
        habitStore.addHabit(habit)
        
        // If identity statement provided, create/link identity
        if !identityStatement.isEmpty {
            let identity = IdentityStatement(
                statement: identityStatement,
                category: .other,
                linkedHabitIds: [habit.id]
            )
            habitStore.addIdentityStatement(identity)
        }
        
        dismiss()
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitStore())
}
