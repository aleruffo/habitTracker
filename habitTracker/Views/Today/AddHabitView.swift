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
    
    @State private var habitName = ""
    @State private var habitDescription = ""
    @State private var selectedIcon = "star.fill"
    @State private var subHabitName = ""
    @State private var subHabits: [SubHabit] = []
    
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
            Form {
                Section("Habit Details") {
                    TextField("Habit Name", text: $habitName)
                    TextField("Trigger (e.g., After breakfast)", text: $habitDescription)
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
                
                Section {
                    HStack {
                        TextField("Sub-habit (optional)", text: $subHabitName)
                        
                        Button {
                            if !subHabitName.isEmpty {
                                subHabits.append(SubHabit(name: subHabitName, description: ""))
                                subHabitName = ""
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        .disabled(subHabitName.isEmpty)
                    }
                    
                    ForEach(subHabits) { subHabit in
                        HStack {
                            Text(subHabit.name)
                            Spacer()
                            Button {
                                subHabits.removeAll { $0.id == subHabit.id }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                } header: {
                    Text("Sub-habits")
                } footer: {
                    Text("Add smaller versions or related tasks for this habit")
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let habit = Habit(
                            name: habitName,
                            description: habitDescription,
                            icon: selectedIcon,
                            subHabits: subHabits
                        )
                        habitStore.addHabit(habit)
                        dismiss()
                    }
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddHabitView()
        .environmentObject(HabitStore())
}
