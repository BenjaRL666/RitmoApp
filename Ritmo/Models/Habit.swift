import Foundation
import SwiftData

enum HabitFrequency: String, CaseIterable, Identifiable {
    case daily = "Diaria", weekly = "Semanal", custom = "Personalizada"
    var id: String { rawValue }
}

@Model
final class Habit {
    @Attribute(.unique) var id: UUID
    var name: String
    var symbol: String
    var frequencyRaw: String
    var weekdays: [Int] // Calendario gregoriano: domingo=1 ... sábado=7
    var target: Int
    var reminderEnabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var repeatAfterMinutes: Int // 0 desactiva el segundo aviso
    var createdAt: Date

    var frequency: HabitFrequency { HabitFrequency(rawValue: frequencyRaw) ?? .daily }

    init(name: String, symbol: String, frequency: HabitFrequency, weekdays: [Int], target: Int,
         reminderEnabled: Bool, reminderHour: Int, reminderMinute: Int, repeatAfterMinutes: Int = 0) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.frequencyRaw = frequency.rawValue
        self.weekdays = weekdays
        self.target = max(1, target)
        self.reminderEnabled = reminderEnabled
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.repeatAfterMinutes = repeatAfterMinutes
        self.createdAt = .now
    }

    func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        guard calendar.startOfDay(for: date) >= calendar.startOfDay(for: createdAt) else { return false }
        return frequency == .daily || weekdays.contains(calendar.component(.weekday, from: date))
    }
}

@Model
final class HabitEntry {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var dayKey: String
    var value: Int

    init(habitID: UUID, dayKey: String, value: Int) {
        self.id = UUID()
        self.habitID = habitID
        self.dayKey = dayKey
        self.value = value
    }
}
