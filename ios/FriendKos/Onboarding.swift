import SwiftUI

struct Tip: Identifiable { let id = UUID(); let icon: String; let title: String; let text: String }

struct OnboardingView: View {
    @EnvironmentObject var store: AppStore
    @State private var page = 0
    private let tips: [Tip] = [
        .init(icon: "hand.wave", title: "Selamat datang di friendkos", text: "Semua datamu mulai dari nol. Ikuti beberapa tips singkat ini agar cepat terbiasa."),
        .init(icon: "wallet.bifold", title: "Dua dompet terpisah", text: "Catat uang tunai dan rekening/e-wallet (GoPay, BCA, dll.) secara terpisah. Tekan tombol + untuk mencatat pemasukan atau pengeluaran."),
        .init(icon: "eye.slash", title: "Sembunyikan saldo", text: "Ketuk ikon mata di kartu saldo agar nominal tidak terlihat orang lain. Atur anggaran bulanan di tab Setelan."),
        .init(icon: "calendar", title: "Jadwal & tugas", text: "Tambahkan jadwal kuliah dan tugas beserta deadline di tab Akademik. Centang tugas yang sudah selesai."),
        .init(icon: "book", title: "Diari pribadi", text: "Tulis catatan singkat di tab Diari. Data tersimpan di perangkatmu; akun Google juga tersinkron ke cloud."),
        .init(icon: "gearshape", title: "Siap dimulai", text: "Kamu bisa membuka tutorial ini lagi kapan saja dari tab Setelan.")
    ]

    var body: some View {
        ZStack {
            LiquidBackground()
            VStack(spacing: 18) {
                HStack { Spacer(); if page < tips.count - 1 { Button("Lewati") { store.finishTips() }.font(.subheadline).foregroundStyle(Theme.muted) } }
                TabView(selection: $page) {
                    ForEach(Array(tips.enumerated()), id: \.element.id) { i, t in
                        VStack(spacing: 16) {
                            Image(systemName: t.icon).font(.system(size: 40)).foregroundStyle(Theme.accent)
                                .frame(width: 88, height: 88).background(.white.opacity(0.7), in: Circle())
                            Text(t.title).font(.system(.title2, design: .rounded).weight(.bold)).foregroundStyle(Theme.text).multilineTextAlignment(.center)
                            Text(t.text).font(.subheadline).foregroundStyle(Theme.muted).multilineTextAlignment(.center)
                        }.padding(26).glassCard().padding(.horizontal, 8).tag(i)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .always))
                Button(page == tips.count - 1 ? "Mulai gunakan" : "Lanjut") {
                    if page == tips.count - 1 { store.finishTips() } else { withAnimation { page += 1 } }
                }.buttonStyle(PrimaryButtonStyle())
            }.padding(20)
        }
    }
}
