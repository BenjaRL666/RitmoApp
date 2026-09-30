import Foundation
import SwiftData
import Combine

@MainActor
final class HabitViewModel: ObservableObject {
    @Published var errorMessage: String?

    func save(_ habit: Habit, context: ModelContext) {
        context.insert(habit)
        commit(context)
    }

    func changeValue(for habit: Habit, on date: Date = .now, by amount: Int,
                     entries: [HabitEntry], habits: [Habit], context: ModelContext) {
        let key = HabitMetrics.key(date)
        if let entry = entries.first(where: { $0.habitID == habit.id && $0.dayKey == key }) {
            entry.value = max(0, entry.value + amount)
        } else if amount > 0 {
            context.insert(HabitEntry(habitID: habit.id, dayKey: key, value: amount))
        }
        commit(context)
        Task { await ReminderService.shared.sync(habits: habits, entries: (try? context.fetch(FetchDescriptor<HabitEntry>())) ?? []) }
    }

    func delete(_ habit: Habit, entries: [HabitEntry], habits: [Habit], context: ModelContext) {
        for entry in entries where entry.habitID == habit.id { context.delete(entry) }
        context.delete(habit)
        commit(context)
        Task { await ReminderService.shared.sync(habits: habits.filter { $0.id != habit.id },
                                                  entries: (try? context.fetch(FetchDescriptor<HabitEntry>())) ?? []) }
    }

    private func commit(_ context: ModelContext) {
        do { try context.save() }
        catch { errorMessage = "No se pudieron guardar los cambios: \(error.localizedDescription)" }
    }
}
