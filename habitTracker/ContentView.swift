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
            
            StatsView()
                .tabItem {
                    Label(Tab.stats.rawValue, systemImage: Tab.stats.icon)
                }
                .tag(Tab.stats)
            
            JourneyView()
                .tabItem {
                    Label(Tab.journey.rawValue, systemImage: Tab.journey.icon)
                }
                .tag(Tab.journey)
            
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

