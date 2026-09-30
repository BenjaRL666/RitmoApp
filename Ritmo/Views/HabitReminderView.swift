import SwiftUI
import SwiftData

struct HabitReminderView: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @Bindable var habit: Habit
    @State private var time = Date.now
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Toggle("Recordatorios activos", isOn: $habit.reminderEnabled)
            if habit.reminderEnabled {
                DatePicker("Hora del primer aviso", selection: $time, displayedComponents: .hourAndMinute)
                    .onChange(of: time) { _, newValue in
                        let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        habit.reminderHour = parts.hour ?? 20
                        habit.reminderMinute = parts.minute ?? 0
                    }
                Picker("Segundo aviso", selection: $habit.repeatAfterMinutes) {
                    Text("Desactivado").tag(0)
                    Text("30 minutos después").tag(30)
                    Text("1 hora después").tag(60)
                    Text("2 horas después").tag(120)
                }
            }
            Text("Se vuelven a programar los avisos al guardar. Revisa los permisos en Configuración.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .navigationTitle("Recordatorios")
        .onAppear {
            time = Calendar.current.date(from: DateComponents(hour: habit.reminderHour,
                                                              minute: habit.reminderMinute)) ?? .now
        }
        .onDisappear {
            do { try context.save() }
            catch { errorMessage = error.localizedDescription }
            Task { await ReminderService.shared.sync(habits: habits, entries: entries) }
        }
        .alert("No se pudo guardar", isPresented: Binding(get: { errorMessage != nil },
                                                          set: { if !$0 { errorMessage = nil } })) {
            Button("Aceptar") { errorMessage = nil }
        } message: { Text(errorMessage ?? "") }
    }
}
