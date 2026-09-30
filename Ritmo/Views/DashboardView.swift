import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @StateObject private var vm = HabitViewModel()
    @State private var creating = false
    @State private var settings = false
    private let theme = AppTheme()

    private var scheduled: [Habit] { habits.filter { $0.isScheduled(on: .now) } }
    private var completedCount: Int { scheduled.filter { HabitMetrics.completed($0, on: .now, entries: entries) }.count }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Hoy").font(.system(size: 38, weight: .bold, design: .rounded))
                        Text(Date.now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                            .foregroundStyle(theme.secondary)
                    }.padding(.top, 12)

                    HabitCard {
                        HStack(spacing: 18) {
                            ProgressRing(progress: scheduled.isEmpty ? 0 : Double(completedCount) / Double(scheduled.count), size: 96)
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(completedCount) de \(scheduled.count)")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                Text("hábitos completados hoy").foregroundStyle(theme.secondary)
                            }
                        }
                    }
                    HStack {
                        Text("Tus hábitos").font(.title2.bold())
                        Spacer()
                        Button { creating = true } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                            .accessibilityLabel("Crear hábito")
                    }
                    if habits.isEmpty {
                        HabitCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Empieza con un hábito").font(.headline)
                                Text("Por ejemplo, caminar o leer diez minutos cada día.").foregroundStyle(theme.secondary)
                                PrimaryButton(title: "Crear mi primer hábito") { creating = true }
                            }
                        }
                    }
                    ForEach(habits) { habit in
                        NavigationLink {
                            HabitDetailView(habit: habit)
                        } label: {
                            HabitCard {
                                HStack(spacing: 14) {
                                    Image(systemName: habit.symbol).font(.title2)
                                        .foregroundStyle(Palette.racingRed).frame(width: 32)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(habit.name).font(.headline)
                                        Text(habit.isScheduled(on: .now)
                                             ? "\(HabitMetrics.value(for: habit, on: .now, entries: entries))/\(habit.target) hoy"
                                             : "Próximo día programado")
                                            .font(.subheadline).foregroundStyle(theme.secondary)
                                    }
                                    Spacer(minLength: 4)
                                    ProgressRing(progress: Double(HabitMetrics.value(for: habit, on: .now, entries: entries)) / Double(habit.target), size: 55)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .foregroundStyle(theme.foreground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { settings = true } label: { Image(systemName: "gearshape") }
                        .accessibilityLabel("Configuración")
                }
            }
            .sheet(isPresented: $creating) { NavigationStack { CreateHabitView() } }
            .sheet(isPresented: $settings) { NavigationStack { SettingsView() } }
        }
    }
}
