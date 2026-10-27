import { useEffect, useState } from "react"
import App from "./App"
import {
  firebaseReady,
  loginWithGoogle,
  logoutFirebase,
  watchAuth,
} from "./firebase"

export type User = { id: string name: string mode: "guest" | "google" }
const KEY = "friendkos:user"

export default function Root() {
  const [splash, setSplash] = useState(true)
  const [user, setUser] = useState<User | null>(() => {
    try {
      return JSON.parse(localStorage.getItem(KEY) || "null")
    } catch {
      return null
    }
  })
  const [guestOpen, setGuestOpen] = useState(false)
  const [name, setName] = useState("")
  const [error, setError] = useState("")

  useEffect(() => {
    const t = window.setTimeout(() => setSplash(false), 1800)
    return () => window.clearTimeout(t)
  }, [])

  useEffect(
    () =>
      watchAuth((u) => {
        if (u)
          signIn({
            id: u.uid,
            name: u.displayName || "Pengguna",
            mode: "google",
          })
      }),
    [],
  )

  const signIn = (u: User) => {
    localStorage.setItem(KEY, JSON.stringify(u))
    setUser(u)
  }
  const logout = async () => {
    localStorage.removeItem(KEY)
    await logoutFirebase()
    setUser(null)
    setGuestOpen(false)
  }

  const google = async () => {
    setError("")
    try {
      const u = await loginWithGoogle()
      signIn({ id: u.uid, name: u.displayName || "Pengguna", mode: "google" })
    } catch (e) {
      setError(
        firebaseReady
          ? "Login Google gagal. Coba lagi."
          : "Firebase belum dikonfigurasi. Isi variabel VITE_FIREBASE_* terlebih dahulu.",
      )
    }
  }
  const guest = (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) return setError("Nama wajib diisi")
    signIn({ id: "guest", name: name.trim(), mode: "guest" })
  }

  if (splash)
    return (
      <div className="splash">
        <div className="splash-logo">
          friend<span>kos</span>
        </div>
      </div>
    )
  if (user) return <App user={user} onLogout={logout} />

  return (
    <div className="splash auth">
      <div className="auth-card glass">
        <div className="splash-logo small">
          friend<span>kos</span>
        </div>
        <p className="subtitle">
          Keuangan, kuliah, dan diari dalam satu tempat.
        </p>
        {!guestOpen ? (
          <>
            <button className="auth-btn google-btn" onClick={google}>
              <svg
                width="20"
                height="20"
                viewBox="0 0 48 48"
                aria-hidden="true"
              >
                <path
                  fill="#EA4335"
                  d="M24 9.5c3.5 0 6.6 1.2 9.1 3.6l6.8-6.8C35.9 2.4 30.4 0 24 0 14.6 0 6.5 5.4 2.6 13.2l7.9 6.1C12.4 13.6 17.7 9.5 24 9.5z"
                />
                <path
                  fill="#4285F4"
                  d="M46.5 24.5c0-1.6-.1-3.1-.4-4.5H24v9h12.7c-.6 3-2.300 5.500-4.800 7.200l7.600 5.900c4.400-4.100 7-10.100 7-17.600z"
                />
                <path
                  fill="#FBBC05"
                  d="M10.500 28.700A14.500 14.500 0 0 1 9.500 24c0-1.600.3-3.200.8-4.700l-7.900-6.100A24 24 0 0 0 0 24c0 3.900.9 7.500 2.600 10.800l7.900-6.100z"
                />
                <path
                  fill="#34A853"
                  d="M24 48c6.500 0 11.900-2.100 15.900-5.800l-7.600-5.900c-2.100 1.400-4.900 2.300-8.300 2.300-6.300 0-11.600-4.100-13.500-9.800l-7.900 6.100C6.500 42.600 14.600 48 24 48z"
                />
              </svg>
              Masuk menggunakan Google
            </button>
            <button
              className="auth-btn alt"
              onClick={() => {
                setError("")
                setGuestOpen(true)
              }}
            >
              Lanjut sebagai tamu
            </button>
          </>
        ) : (
          <form onSubmit={guest}>
            <label>
              Siapa namamu?
              <input
                autoFocus
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Nama kamu"
              />
            </label>
            <button className="primary-button auth-btn" type="submit">
              Mulai
            </button>
            <button
              type="button"
              className="auth-btn alt"
              onClick={() => setGuestOpen(false)}
            >
              Kembali
            </button>
          </form>
        )}
        {error && <p className="auth-error">{error}</p>}
        <small className="auth-note">
          Tamu: data tersimpan di perangkat. Google: tersimpan lokal dan cloud.
        </small>
      </div>
    </div>
  )
}
