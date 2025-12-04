//
//  CalendarGridView.swift
//  habitTracker
//
//  Created by Alessandro Ruffo on 26/11/25.
//

import SwiftUI

struct CalendarGridView: View {
    @EnvironmentObject private var habitStore: HabitStore
    @Binding var selectedMonth: Date
    @Binding var selectedDate: Date?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    
    private var monthDays: [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: selectedMonth)!
        let firstDay = interval.start
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        var currentDate = firstDay
        while currentDate < interval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    
    private func completionCount(for date: Date) -> Int {
        habitStore.habits.filter { $0.isCompleted(for: date) }.count
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            monthNavigationView
            weekdayHeadersView
            daysGridView
            legendView
        }
    }
    
    // MARK: - Subviews
    
    private var monthNavigationView: some View {
        HStack {
            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
            .disabled(Calendar.current.isDate(selectedMonth, equalTo: Date(), toGranularity: .month))
        }
        .padding(.bottom, 8)
    }
    
    private var weekdayHeadersView: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var daysGridView: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(Array(monthDays.enumerated()), id: \.offset) { _, date in
                if let date = date {
                    dayCell(for: date)
                } else {
                    Color.clear
                        .frame(width: 36, height: 36)
                }
            }
        }
    }
    
    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let count = completionCount(for: date)
        let total = max(habitStore.habits.count, 1)
        let isToday = Calendar.current.isDateInToday(date)
        let isSelected = selectedDate.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false
        let isFuture = isFutureDate(date)
        let dayNumber = Calendar.current.component(.day, from: date)
        
        Button {
            if !isFuture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isSelected {
                        selectedDate = nil
                    } else {
                        selectedDate = date
                    }
                }
            }
        } label: {
            dayCellLabel(dayNumber: dayNumber, count: count, total: total, isToday: isToday, isSelected: isSelected, isFuture: isFuture)
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
    }
    
    private func dayCellLabel(dayNumber: Int, count: Int, total: Int, isToday: Bool, isSelected: Bool, isFuture: Bool) -> some View {
        Text("\(dayNumber)")
            .font(.subheadline)
            .fontWeight(isToday ? .bold : .regular)
            .foregroundColor(isFuture ? Color.gray.opacity(0.5) : (count > 0 ? Color.white : Color.primary))
            .frame(width: 36, height: 36)
            .background(dayCellBackground(count: count, total: total, isFuture: isFuture))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday ? Color.blue : (isSelected ? Color.primary : Color.clear), lineWidth: 2)
            )
    }
    
    @ViewBuilder
    private func dayCellBackground(count: Int, total: Int, isFuture: Bool) -> some View {
        if count > 0 && !isFuture {
            Color.green.opacity(0.4 + (Double(count) / Double(total) * 0.6))
        } else {
            Color.clear
        }
    }
    
    private var legendView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green.opacity(0.4))
                    .frame(width: 16, height: 16)
                Text("Some")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.green)
                    .frame(width: 16, height: 16)
                Text("All")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 16, height: 16)
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    CalendarGridView(selectedMonth: .constant(Date()), selectedDate: .constant(nil))
        .environmentObject(HabitStore())
        .padding()
}
