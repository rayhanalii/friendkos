import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var name = ""
    @State private var saved = false
    @State private var budget = ""
    @State private var confirmReset = false
    @State private var confirmDelete = false
    @State private var confirmSignOut = false

    var body: some View {
        VStack(spacing: 14) {
            Header(title: "Setelan.", subtitle: "Atur akun dan data aplikasimu.", onAdd: nil)

            VStack(alignment: .leading, spacing: 12) {
                Text("AKUN").font(.caption2.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                HStack(spacing: 12) {
                    Circle().fill(LinearGradient(colors: [Theme.indigo, Theme.accentLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                        .overlay(Text(String((store.user?.name ?? "?").prefix(2)).uppercased()).font(.subheadline.bold()).foregroundStyle(.white))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(store.user?.name ?? "").font(.headline).foregroundStyle(Theme.text)
                        Label(store.user?.isGoogle == true ? "Akun Google · sinkron cloud" : "Tamu · data di perangkat",
                              systemImage: store.user?.isGoogle == true ? "icloud" : "iphone")
                            .font(.caption).foregroundStyle(Theme.muted)
                    }
                }
                TextField("Nama tampilan", text: $name)
                    .padding(13).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                Button(saved ? "Tersimpan" : "Simpan nama") {
                    store.rename(name); saved = true
                    Task { try? await Task.sleep(for: .seconds(1.5)); saved = false }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }.glassCard()

            VStack(alignment: .leading, spacing: 4) {
                Text("PREFERENSI").font(.caption2.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                Toggle(isOn: $store.hideBalance) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sembunyikan saldo").font(.subheadline.weight(.semibold))
                        Text("Nominal ditampilkan sebagai titik-titik").font(.caption).foregroundStyle(Theme.muted)
                    }
                }.tint(Theme.accent).padding(.top, 6)
            }.glassCard()

            VStack(alignment: .leading, spacing: 8) {
                Text("ANGGARAN BULANAN").font(.caption2.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                TextField("Contoh: 2500000", text: $budget).keyboardType(.numberPad)
                    .padding(13).background(.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 12))
                    .onChange(of: budget) { _, v in store.ledger.budget = Int(v.filter(\.isNumber)) ?? 0 }
                row("Lihat tutorial lagi", "lightbulb", Theme.text) { store.showTips = true }
            }.glassCard()

            VStack(alignment: .leading, spacing: 4) {
                Text("DATA").font(.caption2.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                row("Reset data keuangan & tugas", "arrow.counterclockwise", Theme.text) { confirmReset = true }
                row("Hapus semua data & keluar", "trash", Theme.accent) { confirmDelete = true }
            }.glassCard()

            Button { confirmSignOut = true } label: {
                Label("Keluar", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline.weight(.semibold)).foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(.white.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
            }
            Text("FriendKos 1.0").font(.caption2).foregroundStyle(Theme.muted)
        }
        .onAppear { name = store.user?.name ?? ""; budget = store.ledger.budget > 0 ? String(store.ledger.budget) : "" }
        .confirmationDialog("Reset data ke kondisi awal?", isPresented: $confirmReset, titleVisibility: .visible) {
            Button("Reset", role: .destructive) { store.resetData() }
        }
        .confirmationDialog("Semua data akan dihapus permanen.", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Hapus & keluar", role: .destructive) { Task { await store.deleteDataAndSignOut() } }
        }
        .confirmationDialog(store.user?.isGoogle == true ? "Keluar dari akun?" : "Keluar? Data tamu ini tidak dapat dibuka lagi.", isPresented: $confirmSignOut, titleVisibility: .visible) {
            Button("Keluar", role: .destructive) { store.signOut() }
        }
    }

    func row(_ t: String, _ icon: String, _ c: Color, _ a: @escaping () -> Void) -> some View {
        Button(action: a) {
            HStack { Image(systemName: icon).frame(width: 24); Text(t).font(.subheadline.weight(.semibold)); Spacer(); Image(systemName: "chevron.right").font(.caption) }
                .foregroundStyle(c).padding(.vertical, 10)
        }
    }
}
