//
//  ContentView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

/// The root view of the application containing the tab navigation
struct ContentView: View {
    @State private var selectedTab: Tab = .today
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label(Tab.today.rawValue, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)
            
            ProgressView()
                .tabItem {
                    Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
                }
                .tag(Tab.progress)
            
            LabView()
                .tabItem {
                    Label(Tab.lab.rawValue, systemImage: Tab.lab.icon)
                }
                .tag(Tab.lab)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitStore())
}

