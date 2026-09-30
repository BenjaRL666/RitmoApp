import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearance") private var appearance = "dark"
    @Query private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @State private var notificationStatus = "Comprobando…"

    var body: some View {
        Form {
            Section("Apariencia") {
                Picker("Tema", selection: $appearance) {
                    Text("Oscuro").tag("dark")
                    Text("Claro").tag("light")
                    Text("Sistema").tag("system")
                }
            }
            Section("Notificaciones") {
                LabeledContent("Permiso", value: notificationStatus)
                Button("Solicitar permiso") {
                    Task {
                        await ReminderService.shared.requestAuthorizationIfNeeded()
                        await ReminderService.shared.sync(habits: habits, entries: entries)
                        await updateStatus()
                    }
                }
                Text("La hora y el segundo aviso se eligen al crear cada hábito. Si los avisos están bloqueados, puedes habilitarlos en Ajustes de iOS.")
                    .font(.footnote)
            }
        }
        .navigationTitle("Configuración")
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Listo") { dismiss() } } }
        .task { await updateStatus() }
    }

    @MainActor
    private func updateStatus() async {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .authorized, .provisional: notificationStatus = "Permitidas"
        case .denied: notificationStatus = "Bloqueadas"
        default: notificationStatus = "Sin definir"
        }
    }
}
