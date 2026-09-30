import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    private let theme = AppTheme()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Tu progreso").font(.system(size: 34, weight: .bold, design: .rounded))
                    if habits.isEmpty {
                        HabitCard { Text("Crea hábitos para comparar tus avances.") }
                    }
                    ForEach(habits) { habit in
                        HabitCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Label(habit.name, systemImage: habit.symbol).font(.headline)
                                HStack {
                                    metric("Racha", value: "\(HabitMetrics.streak(habit, entries: entries))")
                                    Spacer()
                                    metric("Semana", value: percent(habit, 7))
                                    Spacer()
                                    metric("30 días", value: percent(habit, 30))
                                }
                                ProgressView(value: HabitMetrics.rate(habit, days: 30, entries: entries))
                                    .tint(Palette.racingRed)
                            }
                        }
                    }
                }.padding(20)
            }
            .background(theme.background.ignoresSafeArea())
            .foregroundStyle(theme.foreground)
            .navigationTitle("Estadísticas")
        }
    }

    private func percent(_ habit: Habit, _ days: Int) -> String {
        "\(Int(HabitMetrics.rate(habit, days: days, entries: entries) * 100))%"
    }

    private func metric(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.system(size: 25, weight: .bold, design: .rounded))
            Text(title).font(.caption).foregroundStyle(theme.secondary)
        }
    }
}
