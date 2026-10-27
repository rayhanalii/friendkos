# FriendKos (SwiftUI, iOS native)

Kode SwiftUI murni (tanpa WebView). Belum dikompilasi di lingkungan ini; perlu Mac + Xcode 15+.

## Setup
1. Xcode → New Project → iOS App (SwiftUI), nama `FriendKos`, minimum iOS 17.
2. Hapus `ContentView.swift` & `FriendKosApp.swift` bawaan, lalu tambahkan semua file di `ios/FriendKos/`.
3. Swift Package Manager:
   - `https://github.com/firebase/firebase-ios-sdk` (FirebaseAuth, FirebaseFirestore)
   - `https://github.com/google/GoogleSignIn-iOS` (GoogleSignIn)
4. Firebase Console: tambah app iOS (bundle ID sama), unduh `GoogleService-Info.plist`, masukkan ke target.
5. Aktifkan Authentication → Google dan buat Firestore; gunakan `firestore.rules` di root repo.
6. Target → Info → URL Types: isi `REVERSED_CLIENT_ID` dari plist.

## Status file Firebase
- `ios/FriendKos/GoogleService-Info.plist` sudah ditambahkan. Di Xcode, pastikan file ini dicentang pada Target Membership.
- Bundle ID di Xcode harus sama dengan `BUNDLE_ID` di file plist tersebut.
- URL Types: isi URL Schemes dengan nilai `REVERSED_CLIENT_ID` dari plist.

## Build di Codemagic
- `codemagic.yaml` (root repo) berisi dua workflow: `ios-compile-check` (tanpa signing) dan `ios-release` (TestFlight).
- Proyek Xcode dibuat otomatis dari `ios/project.yml` memakai XcodeGen, jadi tidak perlu file `.xcodeproj`. Secara lokal: `brew install xcodegen && cd ios && xcodegen generate`.
- Untuk `ios-release`: sambungkan App Store Connect di Codemagic, tambahkan variabel `APP_STORE_APPLE_ID`, dan ganti nama integrasi di yaml.
- `REVERSED_CLIENT_ID` dibaca otomatis dari plist (sudah terisi di plist saat ini).
