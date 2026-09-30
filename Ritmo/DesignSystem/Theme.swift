import SwiftUI

enum Palette {
    static let floralWhite = Color(red: 255/255, green: 249/255, blue: 242/255)
    static let pastelPink = Color(red: 255/255, green: 202/255, blue: 208/255)
    static let racingRed = Color(red: 241/255, green: 2/255, blue: 34/255)
    static let crushedBerry = Color(red: 137/255, green: 35/255, blue: 37/255)
    static let richMahogany = Color(red: 37/255, green: 2/255, blue: 2/255)
}

struct AppTheme: DynamicProperty {
    @Environment(\.colorScheme) private var mode
    var background: Color { mode == .dark ? Palette.richMahogany : Palette.floralWhite }
    var surface: Color { mode == .dark ? Palette.crushedBerry.opacity(0.32) : .white }
    var foreground: Color { mode == .dark ? Palette.floralWhite : Palette.richMahogany }
    var secondary: Color { mode == .dark ? Palette.pastelPink : Palette.crushedBerry }
}

struct HabitCard<Content: View>: View {
    @Environment(\.colorScheme) private var mode
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(mode == .dark ? Palette.crushedBerry.opacity(0.32) : Color.white,
                        in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Palette.pastelPink.opacity(0.14)))
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 15)
        }
        .foregroundStyle(Palette.floralWhite)
        .background(Palette.racingRed, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct ProgressRing: View {
    let progress: Double
    var size: CGFloat = 78
    var body: some View {
        ZStack {
            Circle().stroke(Palette.pastelPink.opacity(0.20), lineWidth: 9)
            Circle().trim(from: 0, to: min(1, max(0, progress)))
                .stroke(Palette.racingRed, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(min(1, max(0, progress)) * 100))%")
                .font(.system(size: 17, weight: .bold, design: .rounded))
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Progreso: \(Int(progress * 100)) por ciento")
    }
}
