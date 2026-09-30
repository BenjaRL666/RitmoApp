import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    @Query private var entries: [HabitEntry]
    @State private var month = Date.now
    private let theme = AppTheme()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                        Spacer()
                        Text(month.formatted(.dateTime.month(.wide).year()).capitalized).font(.title2.bold())
                        Spacer()
                        Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
                            .disabled(Calendar.current.isDate(month, equalTo: .now, toGranularity: .month))
                    }.buttonStyle(.bordered)
                    if habits.isEmpty { Text("Crea un hábito para ver tu calendario.").foregroundStyle(theme.secondary) }
                    ForEach(habits) { habit in
                        HabitCard {
                            Text(habit.name).font(.title3.bold()).padding(.bottom, 8)
                            HabitHeatmap(habit: habit, entries: entries, month: month)
                        }
                    }
                }.padding(20)
            }
            .navigationTitle("Calendario")
            .background(theme.background.ignoresSafeArea())
            .foregroundStyle(theme.foreground)
        }
    }

    private func changeMonth(_ amount: Int) {
        month = Calendar.current.date(byAdding: .month, value: amount, to: month) ?? month
    }
}
