import SwiftUI
import SwiftData

struct HabitDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @StateObject private var vm = HabitViewModel()
    @State private var confirmDelete = false
    let habit: Habit
    private let theme = AppTheme()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                HabitCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 7) {
                            Label(habit.name, systemImage: habit.symbol).font(.title2.bold())
                            Text("\(HabitMetrics.value(for: habit, on: .now, entries: entries)) de \(habit.target) hoy")
                                .foregroundStyle(theme.secondary)
                        }
                        Spacer()
                        ProgressRing(progress: Double(HabitMetrics.value(for: habit, on: .now, entries: entries)) / Double(habit.target))
                    }
                }
                if habit.isScheduled(on: .now) {
                    HStack(spacing: 12) {
                        Button {
                            vm.changeValue(for: habit, by: -1, entries: entries, habits: habits, context: context)
                        } label: { Label("Restar", systemImage: "minus.circle").frame(maxWidth: .infinity) }
                            .disabled(HabitMetrics.value(for: habit, on: .now, entries: entries) == 0)
                        Button {
                            vm.changeValue(for: habit, by: 1, entries: entries, habits: habits, context: context)
                        } label: { Label("Registrar", systemImage: "plus.circle.fill").frame(maxWidth: .infinity) }
                    }
                    .buttonStyle(.borderedProminent).tint(Palette.racingRed)
                }
                NavigationLink("Configurar recordatorios") {
                    HabitReminderView(habit: habit)
                }
                .font(.subheadline.bold())
                HStack(spacing: 12) {
                    HabitCard {
                        Text("Racha").foregroundStyle(theme.secondary)
                        Text("\(HabitMetrics.streak(habit, entries: entries))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("días programados").font(.caption)
                    }
                    HabitCard {
                        Text("Últimos 7 días").foregroundStyle(theme.secondary)
                        Text("\(Int(HabitMetrics.rate(habit, days: 7, entries: entries) * 100))%")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                        Text("de cumplimiento").font(.caption)
                    }
                }
                ForEach(0..<3, id: \.self) { offset in
                    if let month = Calendar.current.date(byAdding: .month, value: -offset, to: .now) {
                        HabitCard { HabitHeatmap(habit: habit, entries: entries, month: month) }
                    }
                }
                Button("Eliminar hábito", role: .destructive) { confirmDelete = true }
                    .frame(maxWidth: .infinity).padding()
            }.padding(20)
        }
        .navigationTitle("Detalle")
        .background(theme.background.ignoresSafeArea())
        .foregroundStyle(theme.foreground)
        .confirmationDialog("¿Eliminar \(habit.name) y su historial?", isPresented: $confirmDelete) {
            Button("Eliminar", role: .destructive) {
                vm.delete(habit, entries: entries, habits: habits, context: context)
                if vm.errorMessage == nil { dismiss() }
            }
        }
        .alert("Error", isPresented: Binding(get: { vm.errorMessage != nil }, set: { if !$0 { vm.errorMessage = nil } })) {
            Button("Aceptar", role: .cancel) { vm.errorMessage = nil }
        } message: { Text(vm.errorMessage ?? "") }
    }
}
