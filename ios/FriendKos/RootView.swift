import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: AppStore
    @State private var splash = true

    var body: some View {
        ZStack {
            LiquidBackground()
            if splash {
                Logo(size: 46).transition(.opacity.combined(with: .scale(scale: 0.94)))
            } else if store.user == nil {
                AuthView().transition(.opacity)
            } else {
                MainTabs().transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: splash)
        .animation(.easeInOut(duration: 0.4), value: store.user?.id)
        .task { try? await Task.sleep(for: .seconds(1.8)); splash = false }
    }
}

struct Logo: View {
    var size: CGFloat
    var body: some View {
        (Text("friend").foregroundStyle(Theme.text) + Text("kos").foregroundStyle(Theme.accent))
            .font(.system(size: size, weight: .bold, design: .rounded)).tracking(-1.5)
    }
}

struct AuthView: View {
    @EnvironmentObject var store: AppStore
    @State private var guest = false
    @State private var name = ""

    var body: some View {
        VStack(spacing: 14) {
            Logo(size: 34)
            Text("Keuangan, kuliah, dan diari dalam satu tempat.")
                .font(.footnote).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
            if !guest {
                Button { Task { await store.signInWithGoogle() } } label: {
                    HStack(spacing: 10) {
                        GoogleG().frame(width: 20, height: 20)
                        Text("Masuk menggunakan Google").font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Theme.text).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                }
                Button("Lanjut sebagai tamu") { guest = true }
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.text)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(.white.opacity(0.6), in: RoundedRectangle(cornerRadius: 14))
            } else {
                TextField("Nama kamu", text: $name)
                    .padding(14).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                Button("Mulai") {
                    let n = name.trimmingCharacters(in: .whitespaces)
                    if n.isEmpty { store.authError = "Nama wajib diisi" } else { store.authError = nil; store.continueAsGuest(name: n) }
                }.buttonStyle(PrimaryButtonStyle())
                Button("Kembali") { guest = false }.font(.footnote).foregroundStyle(Theme.muted)
            }
            if let e = store.authError { Text(e).font(.caption).foregroundStyle(Theme.accent) }
            Text("Tamu: data tersimpan di perangkat. Google: lokal dan cloud.")
                .font(.caption2).foregroundStyle(Theme.muted)
        }
        .padding(26).glassCard().padding(24)
    }
}

/// Logo "G" Google sederhana (empat warna). Ganti dengan aset resmi Google bila tersedia.
struct GoogleG: View {
    private let segments: [(Color, Double)] = [(.red, 0.0), (.yellow, 0.25), (.green, 0.5), (.blue, 0.75)]
    var body: some View {
        ZStack {
            ForEach(0..<segments.count, id: \.self) { i in
                Circle()
                    .trim(from: segments[i].1 + 0.02, to: segments[i].1 + 0.23)
                    .stroke(segments[i].0, style: StrokeStyle(lineWidth: 4, lineCap: .butt))
                    .rotationEffect(.degrees(-45))
            }
            Rectangle().fill(Color.blue).frame(width: 9, height: 4).offset(x: 5)
        }
    }
}
