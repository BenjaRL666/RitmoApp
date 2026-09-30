import SwiftUI

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false
    @State private var selection = 0

    var body: some View {
        if !onboardingComplete {
            OnboardingView { onboardingComplete = true }
        } else {
            TabView(selection: $selection) {
                DashboardView().tabItem { Label("Inicio", systemImage: "house.fill") }.tag(0)
                CalendarView().tabItem { Label("Calendario", systemImage: "calendar") }.tag(1)
                StatisticsView().tabItem { Label("Estadísticas", systemImage: "chart.bar.fill") }.tag(2)
                NotesView().tabItem { Label("Notas", systemImage: "text.bubble.fill") }.tag(3)
            }
            .tint(Palette.racingRed)
        }
    }
}

struct OnboardingView: View {
    let finish: () -> Void
    @State private var page = 0
    private let slides: [(String, String, String)] = [
        ("sparkles", "Encuentra tu ritmo", "Crea hábitos pequeños y claros para ordenar tus días."),
        ("circle.dotted.circle.fill", "Mira tu avance", "Marca cada logro y observa tus rachas y tu calendario."),
        ("bell.badge.fill", "Recibe un impulso", "Elige cuándo quieres recibir un recordatorio. Puedes cambiarlo después.")
    ]

    var body: some View {
        ZStack {
            Palette.richMahogany.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                Image(systemName: slides[page].0).font(.system(size: 92)).foregroundStyle(Palette.racingRed)
                    .accessibilityHidden(true)
                Text(slides[page].1).font(.system(size: 36, weight: .bold, design: .rounded))
                Text(slides[page].2).font(.title3).multilineTextAlignment(.center)
                    .foregroundStyle(Palette.pastelPink)
                Spacer()
                Text("\(page + 1) / \(slides.count)").foregroundStyle(Palette.pastelPink)
                PrimaryButton(title: page == slides.count - 1 ? "Comenzar" : "Siguiente") {
                    if page == slides.count - 1 { finish() } else { withAnimation { page += 1 } }
                }
            }
            .padding(28).foregroundStyle(Palette.floralWhite)
        }
    }
}
