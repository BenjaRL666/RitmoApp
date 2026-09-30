import SwiftUI
import SwiftData

struct CreateHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @StateObject private var vm = HabitViewModel()
    @State private var name = ""
    @State private var symbol = "sparkles"
    @State private var frequency: HabitFrequency = .daily
    @State private var weekdays: Set<Int> = [2]
    @State private var target = 1
    @State private var reminderEnabled = false
    @State private var reminderTime = Calendar.current.date(from: DateComponents(hour: 20)) ?? .now
    @State private var repeatAfter = 0
    private let symbols = ["sparkles", "book.fill", "figure.walk", "drop.fill", "bed.double.fill", "brain.head.profile", "heart.fill", "dumbbell.fill"]
    private let dayNames = [(2,"L"), (3,"M"), (4,"X"), (5,"J"), (6,"V"), (7,"S"), (1,"D")]

    var body: some View {
        Form {
            Section("Tu hábito") {
                TextField("Nombre, por ejemplo: Leer", text: $name)
                    .textInputAutocapitalization(.sentences)
                Picker("Ícono", selection: $symbol) {
                    ForEach(symbols, id: \.self) { Image(systemName: $0).tag($0) }
                }
                Stepper("Meta: \(target) por día programado", value: $target, in: 1...100)
            }
            Section("Frecuencia") {
                Picker("Repetir", selection: $frequency) {
                    ForEach(HabitFrequency.allCases) { Text($0.rawValue).tag($0) }
                }
                if frequency != .daily {
                    Text(frequency == .weekly ? "Elige un día" : "Elige uno o más días")
                        .font(.caption).foregroundStyle(.secondary)
                    HStack {
                        ForEach(dayNames, id: \.0) { item in
                            Button(item.1) {
                                let number = item.0
                                if frequency == .weekly { weekdays = [number] }
                                else if weekdays.contains(number) && weekdays.count > 1 { weekdays.remove(number) }
                                else { weekdays.insert(number) }
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 9)
                            .background(weekdays.contains(item.0) ? Palette.racingRed : Palette.pastelPink.opacity(0.2),
                                        in: RoundedRectangle(cornerRadius: 9))
                            .foregroundStyle(weekdays.contains(item.0) ? Palette.floralWhite : Palette.crushedBerry)
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            Section("Recordatorios") {
                Toggle("Activar avisos", isOn: $reminderEnabled)
                if reminderEnabled {
                    DatePicker("Hora", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    Picker("Segundo aviso si sigue pendiente", selection: $repeatAfter) {
                        Text("Desactivado").tag(0)
                        Text("30 minutos después").tag(30)
                        Text("1 hora después").tag(60)
                        Text("2 horas después").tag(120)
                    }
                    Text("Los avisos se actualizan al abrir la app y al registrar avances.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Nuevo hábito")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    let time = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
                    let habit = Habit(name: name.trimmingCharacters(in: .whitespacesAndNewlines), symbol: symbol,
                                      frequency: frequency, weekdays: frequency == .daily ? [] : weekdays.sorted(),
                                      target: target, reminderEnabled: reminderEnabled,
                                      reminderHour: time.hour ?? 20, reminderMinute: time.minute ?? 0,
                                      repeatAfterMinutes: repeatAfter)
                    vm.save(habit, context: context)
                    guard vm.errorMessage == nil else { return }
                    Task { await ReminderService.shared.requestAuthorizationIfNeeded()
                        await ReminderService.shared.sync(habits: habits + [habit], entries: entries) }
                    dismiss()
                }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .alert("Error", isPresented: Binding(get: { vm.errorMessage != nil }, set: { if !$0 { vm.errorMessage = nil } })) {
            Button("Aceptar", role: .cancel) { vm.errorMessage = nil }
        } message: { Text(vm.errorMessage ?? "") }
    }
}
