import SwiftUI
import SwiftData

@main
struct RitmoApp: App {
    @AppStorage("appearance") private var appearance = "dark"
    @Environment(\.scenePhase) private var scenePhase
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Habit.self, HabitEntry.self)
        } catch {
            fatalError("No se pudo abrir la base local: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(appearance == "system" ? nil : (appearance == "light" ? .light : .dark))
                .task { await ReminderService.shared.requestAuthorizationIfNeeded() }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { refreshReminders() }
                }
        }
        .modelContainer(container)
    }

    private func refreshReminders() {
        let context = ModelContext(container)
        guard let habits = try? context.fetch(FetchDescriptor<Habit>()),
              let entries = try? context.fetch(FetchDescriptor<HabitEntry>()) else { return }
        Task { await ReminderService.shared.sync(habits: habits, entries: entries) }
    }
}
