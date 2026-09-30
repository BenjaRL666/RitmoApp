import Foundation

enum HabitMetrics {
    static func key(_ date: Date, calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    static func value(for habit: Habit, on date: Date, entries: [HabitEntry]) -> Int {
        entries.first { $0.habitID == habit.id && $0.dayKey == key(date) }?.value ?? 0
    }

    static func completed(_ habit: Habit, on date: Date, entries: [HabitEntry]) -> Bool {
        value(for: habit, on: date, entries: entries) >= habit.target
    }

    static func rate(_ habit: Habit, days: Int, entries: [HabitEntry], now: Date = .now,
                     calendar: Calendar = .current) -> Double {
        let dates = (0..<days).compactMap { calendar.date(byAdding: .day, value: -$0, to: now) }
            .filter { habit.isScheduled(on: $0, calendar: calendar) }
        guard !dates.isEmpty else { return 0 }
        return Double(dates.filter { completed(habit, on: $0, entries: entries) }.count) / Double(dates.count)
    }

    static func streak(_ habit: Habit, entries: [HabitEntry], now: Date = .now,
                       calendar: Calendar = .current) -> Int {
        var count = 0
        var current = now
        // Permite continuar la racha si todavía no se ha registrado el día de hoy.
        if habit.isScheduled(on: current, calendar: calendar) && !completed(habit, on: current, entries: entries) {
            current = calendar.date(byAdding: .day, value: -1, to: current) ?? current
        }
        for _ in 0..<3660 {
            guard calendar.startOfDay(for: current) >= calendar.startOfDay(for: habit.createdAt) else { break }
            if habit.isScheduled(on: current, calendar: calendar) {
                guard completed(habit, on: current, entries: entries) else { break }
                count += 1
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = previous
        }
        return count
    }
}
