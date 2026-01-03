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
    @State private var showingAddBehavior = false
    @State private var selectedExperiment: Experiment?
    @State private var selectedSection = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Section picker
                Picker("Section", selection: $selectedSection) {
                    Text("Scorecard").tag(0)
                    Text("Rewards").tag(1)
                    Text("Experiments").tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                ScrollView {
                    switch selectedSection {
                    case 0:
                        habitScorecardSection
                    case 1:
                        temptationBundlingSection
                    case 2:
                        experimentSection
                    default:
                        EmptyView()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Habit Lab")
            .sheet(isPresented: $showingAddReward) {
                AddRewardView()
            }
            .sheet(isPresented: $showingAddExperiment) {
                AddExperimentView()
            }
            .sheet(isPresented: $showingAddBehavior) {
                AddBehaviorView()
            }
            .sheet(item: $selectedExperiment) { experiment in
                ExperimentDetailView(experiment: experiment)
            }
        }
    }
    
    // MARK: - Habit Scorecard Section
    
    private var habitScorecardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "list.clipboard.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("Habit Scorecard")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        showingAddBehavior = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
                
                Text("\"The process of behavior change always starts with awareness.\"")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.secondary)
                
                Text("List your daily behaviors and rate them: + (positive), = (neutral), - (negative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Balance Score
            if !habitStore.habitScorecard.behaviors.isEmpty {
                scorecardSummary
            }
            
            // Behaviors by category
            if habitStore.habitScorecard.behaviors.isEmpty {
                emptyScorecardView
            } else {
                ForEach(BehaviorCategory.allCases, id: \.self) { category in
                    let behaviors = habitStore.habitScorecard.behaviors.filter { $0.category == category }
                    if !behaviors.isEmpty {
                        behaviorCategorySection(category: category, behaviors: behaviors)
                    }
                }
            }
            
            // Suggestions
            if habitStore.habitScorecard.behaviors.isEmpty {
                suggestionSection
            }
        }
        .padding()
    }
    
    private var scorecardSummary: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                VStack {
                    Text("\(habitStore.habitScorecard.positiveCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Good")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(habitStore.habitScorecard.neutralCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                    Text("Neutral")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(habitStore.habitScorecard.negativeCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                    Text("Bad")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Balance gauge
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(max(0, habitStore.habitScorecard.balanceScore + 100)) / 200)
                        .stroke(
                            habitStore.habitScorecard.balanceScore > 0 ? Color.green :
                            habitStore.habitScorecard.balanceScore < 0 ? Color.red : Color.gray,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(habitStore.habitScorecard.balanceScore > 0 ? "+" : "")\(habitStore.habitScorecard.balanceScore)")
                            .font(.system(size: 14, weight: .bold))
                        Text("Score")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func behaviorCategorySection(category: BehaviorCategory, behaviors: [ScorecardBehavior]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(.secondary)
                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ForEach(behaviors) { behavior in
                behaviorRow(behavior)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func behaviorRow(_ behavior: ScorecardBehavior) -> some View {
        HStack(spacing: 12) {
            Image(systemName: behavior.rating.icon)
                .font(.title3)
                .foregroundStyle(ratingColor(behavior.rating))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(behavior.behavior)
                    .font(.subheadline)
                
                Text(behavior.rating.actionAdvice)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if behavior.linkedHabitId != nil {
                Image(systemName: "link.circle.fill")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(ratingColor(behavior.rating).opacity(0.05))
        .contextMenu {
            Button {
                var updated = behavior
                updated.rating = .positive
                habitStore.updateScorecardBehavior(updated)
            } label: {
                Label("Mark as Positive (+)", systemImage: "plus.circle")
            }
            
            Button {
                var updated = behavior
                updated.rating = .neutral
                habitStore.updateScorecardBehavior(updated)
            } label: {
                Label("Mark as Neutral (=)", systemImage: "equal.circle")
            }
            
            Button {
                var updated = behavior
                updated.rating = .negative
                habitStore.updateScorecardBehavior(updated)
            } label: {
                Label("Mark as Negative (-)", systemImage: "minus.circle")
            }
            
            Divider()
            
            if behavior.rating == .positive && behavior.linkedHabitId == nil {
                Button {
                    let habit = habitStore.convertBehaviorToHabit(behavior)
                    habitStore.addHabit(habit)
                } label: {
                    Label("Convert to Habit", systemImage: "arrow.right.circle")
                }
            }
            
            Button(role: .destructive) {
                habitStore.deleteScorecardBehavior(behavior)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private func ratingColor(_ rating: BehaviorRating) -> Color {
        switch rating {
        case .positive: return .green
        case .neutral: return .gray
        case .negative: return .red
        }
    }
    
    private var emptyScorecardView: some View {
        VStack(spacing: 12) {
            Image(systemName: "list.clipboard")
                .font(.largeTitle)
                .foregroundStyle(.blue)
            
            Text("Start Your Scorecard")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("List your daily behaviors to become aware of your habits")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Common Behaviors")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("Tap to add to your scorecard")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(ScorecardSuggestions.commonMorningBehaviors.prefix(4), id: \.self) { suggestion in
                    Button {
                        let behavior = ScorecardBehavior(behavior: suggestion, category: .morning)
                        habitStore.addScorecardBehavior(behavior)
                    } label: {
                        Text(suggestion)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Temptation Bundling Section
    
    private var temptationBundlingSection: some View {
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
            
            Text("\"After I [HABIT I NEED], I will [HABIT I WANT].\"")
                .font(.caption)
                .italic()
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
        .padding()
    }
    
    // MARK: - Experiment Section
    
    private var experimentSection: some View {
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
        .padding()
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

// MARK: - Flow Layout for Suggestions

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Add Behavior View

struct AddBehaviorView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var behaviorText = ""
    @State private var selectedRating: BehaviorRating = .neutral
    @State private var selectedCategory: BehaviorCategory = .morning
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("\"Does this behavior help me become the type of person I wish to be?\"")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                }
                
                Section("Behavior") {
                    TextField("What do you do?", text: $behaviorText)
                }
                
                Section("Rating") {
                    Picker("Rating", selection: $selectedRating) {
                        ForEach(BehaviorRating.allCases, id: \.self) { rating in
                            HStack {
                                Image(systemName: rating.icon)
                                Text(rating.displayName)
                            }
                            .tag(rating)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(selectedRating.actionAdvice)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("When/Where") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(BehaviorCategory.allCases, id: \.self) { category in
                            Label(category.displayName, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Behavior")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let behavior = ScorecardBehavior(
                            behavior: behaviorText,
                            rating: selectedRating,
                            category: selectedCategory
                        )
                        habitStore.addScorecardBehavior(behavior)
                        dismiss()
                    }
                    .disabled(behaviorText.isEmpty)
                }
            }
        }
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
