import Foundation
import UserNotifications

final class ReminderService {
    static let shared = ReminderService()
    private let center = UNUserNotificationCenter.current()
    private let prefix = "ritmo."
    private init() {}

    func requestAuthorizationIfNeeded() async {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        }
    }

    // Ventana móvil de siete días; iOS admite un número limitado de avisos pendientes.
    // Al abrir la app o registrar un hábito se cancela y reconstruye esta ventana.
    func sync(habits: [Habit], entries: [HabitEntry], now: Date = .now) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix(prefix) })
        guard await center.notificationSettings().authorizationStatus == .authorized else { return }

        let calendar = Calendar.current
        var available = max(0, 60 - pending.filter { !$0.identifier.hasPrefix(prefix) }.count)
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { continue }
            for habit in habits where habit.reminderEnabled && habit.isScheduled(on: day) {
                if HabitMetrics.completed(habit, on: day, entries: entries) { continue }
                guard let first = calendar.date(bySettingHour: habit.reminderHour, minute: habit.reminderMinute,
                                                second: 0, of: day) else { continue }
                let times = [first] + (habit.repeatAfterMinutes > 0
                    ? [first.addingTimeInterval(TimeInterval(habit.repeatAfterMinutes * 60))] : [])
                for (index, fireDate) in times.enumerated() where fireDate > now && available > 0 {
                    // El segundo aviso no debe salirse del día programado.
                    guard calendar.isDate(fireDate, inSameDayAs: day) else { continue }
                    let content = UNMutableNotificationContent()
                    content.title = index == 0 ? "Es hora de \(habit.name)" : "Aún puedes completar \(habit.name)"
                    content.body = "Un paso más para mantener tu ritmo."
                    content.sound = .default
                    let id = "\(prefix)\(habit.id.uuidString).\(HabitMetrics.key(day)).\(index)"
                    let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
                    try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
                    available -= 1
                }
            }
        }
    }
}
