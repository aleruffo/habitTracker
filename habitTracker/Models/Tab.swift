//
//  Tab.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import Foundation

/// Defines the available tabs in the application
enum Tab: String, CaseIterable {
    case today = "Today"
    case progress = "Progress"
    case lab = "Lab"
    
    var icon: String {
        switch self {
        case .today: return "calendar"
        case .progress: return "chart.bar"
        case .lab: return "flask"
        }
    }
}
