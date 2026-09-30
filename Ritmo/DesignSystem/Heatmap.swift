import SwiftUI

struct HabitHeatmap: View {
    let habit: Habit
    let entries: [HabitEntry]
    let month: Date
    private let calendar = Calendar.current

    private var days: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else { return [] }
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        return Array(repeating: nil, count: leading) + range.compactMap {
            calendar.date(byAdding: .day, value: $0 - 1, to: start)
        }.map(Optional.some)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(month.formatted(.dateTime.month(.wide).year()).capitalized)
                .font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 7), spacing: 12) {
                ForEach(Array(days.enumerated()), id: \.offset) { item in
                    if let day = item.element {
                        let scheduled = habit.isScheduled(on: day)
                        let done = HabitMetrics.completed(habit, on: day, entries: entries)
                        Circle()
                            .fill(done ? Palette.racingRed : scheduled ? Palette.pastelPink.opacity(0.42) : Palette.pastelPink.opacity(0.12))
                            .frame(width: 18, height: 18)
                            .frame(maxWidth: .infinity)
                            .accessibilityLabel("\(day.formatted(date: .abbreviated, time: .omitted)): \(done ? "cumplido" : scheduled ? "pendiente" : "sin programar")")
                    } else {
                        Color.clear.frame(height: 18)
                    }
                }
            }
            HStack(spacing: 14) {
                Label("Cumplido", systemImage: "circle.fill").foregroundStyle(Palette.racingRed)
                Label("Programado", systemImage: "circle.fill").foregroundStyle(Palette.pastelPink)
            }.font(.caption)
        }
    }
}
