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
    case stats = "Stats"
    case journey = "Journey"
    case lab = "Lab"
    
    var icon: String {
        switch self {
        case .today: return "calendar"
        case .stats: return "chart.xyaxis.line"
        case .journey: return "flag.fill"
        case .lab: return "flask"
        }
    }
}
