import SwiftUI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

struct AppUser: Codable { var id: String; var name: String; var isGoogle: Bool }
struct TaskItem: Identifiable, Codable { var id = UUID(); var title: String; var meta: String; var due: String; var urgent = false; var done = false }
struct ClassItem: Identifiable, Codable { var id = UUID(); var name: String; var time: String; var room: String }
struct DiaryEntry: Identifiable, Codable { var id = UUID(); var text: String; var date = Date() }

/// Semua nilai awal 0 / kosong: pengguna baru tidak mewarisi data apa pun.
struct Ledger: Codable { var cash = 0; var digital = 0; var expense = 0; var budget = 0 }

struct Persisted: Codable {
    var ledger = Ledger(); var tasks: [TaskItem] = []; var classes: [ClassItem] = []; var diary: [DiaryEntry] = []
    init() {}
    init(from d: Decoder) throws {
        let c = try d.container(keyedBy: CodingKeys.self)
        ledger = try c.decodeIfPresent(Ledger.self, forKey: .ledger) ?? Ledger()
        tasks = try c.decodeIfPresent([TaskItem].self, forKey: .tasks) ?? []
        classes = try c.decodeIfPresent([ClassItem].self, forKey: .classes) ?? []
        diary = try c.decodeIfPresent([DiaryEntry].self, forKey: .diary) ?? []
    }
}

@MainActor
final class AppStore: ObservableObject {
    @Published var user: AppUser? { didSet { UserDefaults.standard.set(try? JSONEncoder().encode(user), forKey: "fk.user") } }
    @Published var ledger = Ledger() { didSet { persist() } }
    @Published var tasks: [TaskItem] = [] { didSet { persist() } }
    @Published var classes: [ClassItem] = [] { didSet { persist() } }
    @Published var diary: [DiaryEntry] = [] { didSet { persist() } }
    @Published var hideBalance = false
    @Published var authError: String?
    @Published var showTips = false
    private var loading = false

    init() {
        if let d = UserDefaults.standard.data(forKey: "fk.user"), let u = try? JSONDecoder().decode(AppUser.self, from: d) {
            user = u; loadLocal(); updateTips(); Task { await loadCloud() }
        }
    }

    private var key: String { "fk.data.\(user?.id ?? "none")" }
    private var tipsKey: String { "fk.tips.\(user?.id ?? "none")" }

    private func apply(_ p: Persisted) { ledger = p.ledger; tasks = p.tasks; classes = p.classes; diary = p.diary }
    private func clearAll() { loading = true; apply(Persisted()); loading = false }

    func loadLocal() {
        loading = true; defer { loading = false }
        if let d = UserDefaults.standard.data(forKey: key), let p = try? JSONDecoder().decode(Persisted.self, from: d) { apply(p) }
        else { apply(Persisted()) } // akun baru: mulai dari nol
    }

    private func snapshot() -> Persisted { var p = Persisted(); p.ledger = ledger; p.tasks = tasks; p.classes = classes; p.diary = diary; return p }

    private func persist() {
        guard !loading, let user, let d = try? JSONEncoder().encode(snapshot()) else { return }
        UserDefaults.standard.set(d, forKey: key)
        guard user.isGoogle, let json = String(data: d, encoding: .utf8) else { return }
        Firestore.firestore().collection("users").document(user.id).setData(["data": json, "updatedAt": Date().timeIntervalSince1970])
    }

    func loadCloud() async {
        guard let user, user.isGoogle else { return }
        guard let snap = try? await Firestore.firestore().collection("users").document(user.id).getDocument(),
              let json = snap.data()?["data"] as? String, let d = json.data(using: .utf8),
              let p = try? JSONDecoder().decode(Persisted.self, from: d) else { return }
        loading = true; apply(p); loading = false
        UserDefaults.standard.set(d, forKey: key)
    }

    // MARK: Tutorial
    func updateTips() { showTips = !UserDefaults.standard.bool(forKey: tipsKey) }
    func finishTips() { UserDefaults.standard.set(true, forKey: tipsKey); showTips = false }

    // MARK: Auth
    func continueAsGuest(name: String) {
        // ID unik per tamu, sehingga tamu baru tidak memakai data tamu sebelumnya.
        user = AppUser(id: "guest-" + UUID().uuidString, name: name, isGoogle: false)
        loadLocal(); updateTips()
    }

    func signInWithGoogle() async {
        authError = nil
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else { throw URLError(.badURL) }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            guard let root = UIApplication.shared.connectedScenes.compactMap({ ($0 as? UIWindowScene)?.keyWindow }).first?.rootViewController
            else { throw URLError(.cannotFindHost) }
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: root)
            guard let token = result.user.idToken?.tokenString else { throw URLError(.userAuthenticationRequired) }
            let cred = GoogleAuthProvider.credential(withIDToken: token, accessToken: result.user.accessToken.tokenString)
            let auth = try await Auth.auth().signIn(with: cred)
            user = AppUser(id: auth.user.uid, name: auth.user.displayName ?? "Pengguna", isGoogle: true)
            loadLocal(); updateTips(); await loadCloud()
        } catch { authError = "Login Google gagal. Coba lagi." }
    }

    func signOut() {
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        clearAll(); hideBalance = false; showTips = false
        user = nil
    }

    // MARK: Setelan
    func rename(_ newName: String) {
        let n = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, var u = user else { return }
        u.name = n; user = u
    }
    func resetData() { apply(Persisted()) }
    func deleteDataAndSignOut() async {
        guard let u = user else { return }
        UserDefaults.standard.removeObject(forKey: key); UserDefaults.standard.removeObject(forKey: tipsKey)
        if u.isGoogle { try? await Firestore.firestore().collection("users").document(u.id).delete() }
        signOut()
    }

    // MARK: Data
    func add(amount: Int, income: Bool, cash: Bool) {
        let delta = income ? amount : -amount
        if cash { ledger.cash = max(0, ledger.cash + delta) } else { ledger.digital = max(0, ledger.digital + delta) }
        if !income { ledger.expense += amount }
    }
}
