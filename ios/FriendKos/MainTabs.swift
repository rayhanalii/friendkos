import SwiftUI

struct MainTabs: View {
    @EnvironmentObject var store: AppStore
    @State private var showAdd = false
    @State private var addIncome = false

    var body: some View {
        TabView {
            tab("Beranda", "square.grid.2x2") { Dashboard(showAdd: open) }
            tab("Keuangan", "wallet.bifold") { FinanceView(showAdd: open) }
            tab("Akademik", "calendar") { AcademicView() }
            tab("Diari", "book") { DiaryView() }
            tab("Setelan", "gearshape") { SettingsView() }
        }
        .tint(Theme.accent)
        .fullScreenCover(isPresented: Binding(get: { store.showTips }, set: { if !$0 { store.finishTips() } })) { OnboardingView() }
        .sheet(isPresented: $showAdd) { AddTransactionSheet(income: addIncome).presentationDetents([.medium]) }
    }

    func open(_ income: Bool) { addIncome = income; showAdd = true }

    func tab<C: View>(_ t: String, _ icon: String, @ViewBuilder _ c: () -> C) -> some View {
        NavigationStack { ZStack { LiquidBackground(); ScrollView { c().padding(16) } } .navigationBarTitleDisplayMode(.inline).toolbar(.hidden, for: .navigationBar) }
            .tabItem { Label(t, systemImage: icon) }
    }
}

struct Header: View {
    @EnvironmentObject var store: AppStore
    var title: String; var subtitle: String; var onAdd: (() -> Void)?
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(.title, design: .rounded).weight(.bold)).foregroundStyle(Theme.text)
                Text(subtitle).font(.footnote).foregroundStyle(Theme.muted)
            }
            Spacer()
            Menu {
                Text(store.user?.name ?? "")
                Button("Keluar", role: .destructive) { store.signOut() }
            } label: {
                Circle().fill(LinearGradient(colors: [Theme.indigo, Theme.accentLight], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 38, height: 38)
                    .overlay(Text(String((store.user?.name ?? "?").prefix(2)).uppercased()).font(.caption.bold()).foregroundStyle(.white))
            }
            if let onAdd { Button(action: onAdd) { Image(systemName: "plus") }.buttonStyle(PrimaryButtonStyle()) }
        }
    }
}

struct BalanceCard: View {
    @EnvironmentObject var store: AppStore
    func m(_ v: Int) -> String { store.hideBalance ? "Rp ••••••" : rupiah(v) }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total saldo bulan ini").font(.caption).foregroundStyle(Theme.muted)
                    Text(m(store.ledger.cash + store.ledger.digital)).font(.system(size: 30, weight: .bold, design: .rounded)).foregroundStyle(Theme.text)
                }
                Spacer()
                Button { withAnimation { store.hideBalance.toggle() } } label: {
                    Image(systemName: store.hideBalance ? "eye.slash" : "eye").foregroundStyle(Theme.muted)
                        .frame(width: 40, height: 40).background(.white.opacity(0.7), in: Circle())
                }.accessibilityLabel(store.hideBalance ? "Tampilkan saldo" : "Sembunyikan saldo")
            }
            Divider()
            HStack {
                ledger("Uang tunai", store.ledger.cash, "banknote", Theme.accent)
                Spacer()
                ledger("Rekening & e-wallet", store.ledger.digital, "creditcard", Theme.indigo)
            }
            Divider()
            HStack { Text("Pengeluaran bulan ini"); Spacer(); Text(store.ledger.budget > 0 ? "\(m(store.ledger.expense)) dari \(m(store.ledger.budget))" : "\(m(store.ledger.expense)) · anggaran belum diatur") }
                .font(.caption2).foregroundStyle(Theme.muted)
            ProgressView(value: store.ledger.budget > 0 ? min(Double(store.ledger.expense) / Double(store.ledger.budget), 1) : 0).tint(Theme.accent)
        }.glassCard()
    }
    func ledger(_ t: String, _ v: Int, _ icon: String, _ c: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(c).frame(width: 30, height: 30).background(c.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
            VStack(alignment: .leading) { Text(t).font(.caption2).foregroundStyle(Theme.muted); Text(m(v)).font(.footnote.bold()).foregroundStyle(Theme.text) }
        }
    }
}

struct QuickActions: View {
    var showAdd: (Bool) -> Void
    var body: some View {
        HStack(spacing: 10) {
            q("Pemasukan", "arrow.down", .indigo) { showAdd(true) }
            q("Pengeluaran", "arrow.up", Theme.accent) { showAdd(false) }
        }
    }
    func q(_ t: String, _ i: String, _ c: Color, _ a: @escaping () -> Void) -> some View {
        Button(action: a) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: i).foregroundStyle(c).frame(width: 32, height: 32).background(c.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                Text(t).font(.footnote.bold()).foregroundStyle(Theme.text)
            }.glassCard()
        }
    }
}

struct CardTitle: View {
    let eyebrow: String; let title: String; let onAdd: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow).font(.caption2.bold()).tracking(1.5).foregroundStyle(Theme.muted)
                Text(title).font(.headline).foregroundStyle(Theme.text)
            }
            Spacer()
            Button(action: onAdd) { Image(systemName: "plus").font(.footnote.bold()).foregroundStyle(Theme.accent)
                .frame(width: 32, height: 32).background(Theme.accent.opacity(0.1), in: Circle()) }
        }
    }
}

struct ScheduleCard: View {
    @EnvironmentObject var store: AppStore
    @State private var show = false
    @State private var name = ""; @State private var time = ""; @State private var room = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardTitle(eyebrow: "JADWAL KULIAH", title: store.classes.isEmpty ? "Belum ada jadwal" : "\(store.classes.count) kelas") { show = true }
            if store.classes.isEmpty { EmptyHint(icon: "calendar.badge.plus", text: "Ketuk + untuk menambah jadwal kuliah") }
            ForEach(store.classes) { c in
                HStack(spacing: 12) {
                    Text(c.time).font(.caption.bold()).foregroundStyle(Theme.text).frame(width: 56)
                    VStack(alignment: .leading, spacing: 3) { Text(c.name).font(.footnote.bold()); if !c.room.isEmpty { Text(c.room).font(.caption2).foregroundStyle(Theme.muted) } }
                    Spacer()
                    Button { store.classes.removeAll { $0.id == c.id } } label: { Image(systemName: "trash").font(.caption).foregroundStyle(Theme.muted) }
                }.padding(12).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            }
        }.glassCard()
        .sheet(isPresented: $show) {
            FormSheet(title: "Tambah jadwal", fields: [("Mata kuliah", $name), ("Jam (mis. 08:00)", $time), ("Ruangan (opsional)", $room)]) {
                guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
                store.classes.append(ClassItem(name: name, time: time, room: room)); name = ""; time = ""; room = ""; return true
            }
        }
    }
}

struct TasksCard: View {
    @EnvironmentObject var store: AppStore
    @State private var show = false
    @State private var title = ""; @State private var meta = ""; @State private var due = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardTitle(eyebrow: "TUGAS", title: store.tasks.isEmpty ? "Belum ada tugas" : "\(store.tasks.filter { !$0.done }.count) tersisa") { show = true }
            if store.tasks.isEmpty { EmptyHint(icon: "checklist", text: "Ketuk + untuk menambah tugas") }
            ForEach($store.tasks) { $t in
                HStack(spacing: 10) {
                    Button { t.done.toggle() } label: { Image(systemName: t.done ? "checkmark.square.fill" : "square").foregroundStyle(t.done ? Theme.indigo : Theme.muted) }
                    VStack(alignment: .leading, spacing: 2) { Text(t.title).font(.footnote.bold()).strikethrough(t.done); if !t.meta.isEmpty { Text(t.meta).font(.caption2).foregroundStyle(Theme.muted) } }
                    Spacer()
                    if !t.due.isEmpty { Label(t.due, systemImage: "clock").font(.caption2).foregroundStyle(Theme.muted) }
                    Button { store.tasks.removeAll { $0.id == t.id } } label: { Image(systemName: "trash").font(.caption).foregroundStyle(Theme.muted) }
                }.opacity(t.done ? 0.5 : 1)
            }
        }.glassCard()
        .sheet(isPresented: $show) {
            FormSheet(title: "Tambah tugas", fields: [("Judul tugas", $title), ("Mata kuliah (opsional)", $meta), ("Deadline (mis. Besok, 10:00)", $due)]) {
                guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
                store.tasks.append(TaskItem(title: title, meta: meta, due: due)); title = ""; meta = ""; due = ""; return true
            }
        }
    }
}

struct DiaryCard: View {
    @EnvironmentObject var store: AppStore
    @State private var show = false
    @State private var text = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardTitle(eyebrow: "DIARI", title: "Ruang kecilmu") { show = true }
            if store.diary.isEmpty { EmptyHint(icon: "square.and.pencil", text: "Ketuk + untuk menulis catatan pertama") }
            ForEach(store.diary.sorted { $0.date > $1.date }) { e in
                VStack(alignment: .leading, spacing: 4) {
                    HStack { Text(e.date.formatted(date: .abbreviated, time: .shortened)).font(.caption2).foregroundStyle(Theme.accent); Spacer()
                        Button { store.diary.removeAll { $0.id == e.id } } label: { Image(systemName: "trash").font(.caption).foregroundStyle(Theme.muted) } }
                    Text(e.text).font(.footnote).foregroundStyle(Theme.text)
                }.padding(12).frame(maxWidth: .infinity, alignment: .leading).background(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 14))
            }
            Label("Tersimpan aman di perangkatmu", systemImage: "lock.fill").font(.caption2).foregroundStyle(Theme.muted)
        }.glassCard()
        .sheet(isPresented: $show) {
            FormSheet(title: "Catatan baru", fields: [("Apa yang terjadi hari ini?", $text)], multiline: true) {
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
                store.diary.append(DiaryEntry(text: text)); text = ""; return true
            }
        }
    }
}

struct Dashboard: View {
    @EnvironmentObject var store: AppStore
    var showAdd: (Bool) -> Void
    var body: some View {
        VStack(spacing: 14) {
            Header(title: "Halo, \(store.user?.name ?? "").", subtitle: "Mulai catat keuangan, jadwal, dan harimu.") { showAdd(false) }
            BalanceCard(); QuickActions(showAdd: showAdd); ScheduleCard(); TasksCard(); DiaryCard()
        }
    }
}
struct FinanceView: View {
    var showAdd: (Bool) -> Void
    var body: some View { VStack(spacing: 14) { Header(title: "Keuanganmu.", subtitle: "Pantau saldo dan pengeluaran.") { showAdd(false) }; BalanceCard(); QuickActions(showAdd: showAdd) } }
}
struct AcademicView: View {
    var body: some View { VStack(spacing: 14) { Header(title: "Agenda akademik.", subtitle: "Jadwal dan tugas hari ini.", onAdd: nil); ScheduleCard(); TasksCard() } }
}
struct DiaryView: View {
    var body: some View { VStack(spacing: 14) { Header(title: "Ruang kecilmu.", subtitle: "Catat cerita dengan aman.", onAdd: nil); DiaryCard() } }
}

struct AddTransactionSheet: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State var income: Bool
    @State private var amount = ""
    @State private var cash = true
    @State private var note = ""
    @State private var error = false

    init(income: Bool) { _income = State(initialValue: income) }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Jenis", selection: $income) { Text("Pengeluaran").tag(false); Text("Pemasukan").tag(true) }.pickerStyle(.segmented)
                Section("Nominal") { TextField("0", text: $amount).keyboardType(.numberPad).font(.title2.bold()) }
                Picker("Sumber dana", selection: $cash) { Text("Uang tunai").tag(true); Text("Rekening & e-wallet").tag(false) }
                TextField("Catatan (opsional)", text: $note)
                if error { Text("Masukkan nominal transaksi").foregroundStyle(Theme.accent).font(.caption) }
                Button("Simpan transaksi") {
                    guard let v = Int(amount.filter(\.isNumber)), v > 0 else { error = true; return }
                    store.add(amount: v, income: income, cash: cash); dismiss()
                }.buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle(income ? "Catat pemasukan" : "Catat pengeluaran").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Tutup") { dismiss() } } }
        }
    }
}
