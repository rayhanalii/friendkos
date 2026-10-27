import SwiftUI

enum Theme {
    static let accent = Color(red: 0.93, green: 0.31, blue: 0.41)
    static let accentLight = Color(red: 1.0, green: 0.47, blue: 0.55)
    static let indigo = Color(red: 0.46, green: 0.42, blue: 0.86)
    static let text = Color(red: 0.12, green: 0.13, blue: 0.19)
    static let muted = Color(red: 0.57, green: 0.59, blue: 0.64)
}

/// Latar putih bersih dengan gradasi cair pink/biru.
struct LiquidBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.98, blue: 0.99)
            Circle().fill(Color.pink.opacity(0.22)).frame(width: 320).blur(radius: 70).offset(x: 140, y: -300)
            Circle().fill(Color.blue.opacity(0.18)).frame(width: 300).blur(radius: 70).offset(x: -150, y: -180)
            Circle().fill(Color.purple.opacity(0.14)).frame(width: 320).blur(radius: 80).offset(x: 80, y: 340)
        }.ignoresSafeArea()
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(.white.opacity(0.9), lineWidth: 1))
            .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }
}
extension View { func glassCard() -> some View { modifier(GlassCard()) } }

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold)).foregroundStyle(.white)
            .padding(.horizontal, 18).padding(.vertical, 13)
            .background(LinearGradient(colors: [Theme.accentLight, Theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing), in: Capsule())
            .shadow(color: Theme.accent.opacity(0.35), radius: 14, y: 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

func rupiah(_ v: Int) -> String {
    let f = NumberFormatter(); f.numberStyle = .decimal; f.groupingSeparator = "."
    return "Rp " + (f.string(from: NSNumber(value: v)) ?? "\(v)")
}
