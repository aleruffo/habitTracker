//
//  habitTrackerApp.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

@main
struct HabitTrackerApp: App {
    @StateObject private var habitStore = HabitStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitStore)
        }
    }
}
