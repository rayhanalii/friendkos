import { useEffect, useRef, useState, type ReactNode } from "react"
import type { User } from "./Root"
import { loadCloud, saveCloud } from "./firebase"

type IconName = "grid" | "wallet" | "calendar" | "book" | "settings" | "bell" | "eye" | "arrowUp" | "arrowDown" | "plus" | "more" | "check" | "clock" | "home" | "eyeOff"

function Icon({ name, size = 20 }: { name: IconName size?: number }) {
  const paths: Record<IconName, ReactNode> = {
    grid: (
      <>
        <rect x="3" y="3" width="7" height="7" rx="2" />
        <rect x="14" y="3" width="7" height="7" rx="2" />
        <rect x="3" y="14" width="7" height="7" rx="2" />
        <rect x="14" y="14" width="7" height="7" rx="2" />
      </>
    ),
    wallet: (
      <>
        <path d="M4 6.5h14a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-12a2 2 0 0 1 2-2h11" />
        <path d="M16 11h4v5h-4a2.5 2.5 0 0 1 0-5Z" />
        <circle cx="16" cy="13.5" r=".4" fill="currentColor" />
      </>
    ),
    calendar: (
      <>
        <rect x="3" y="5" width="18" height="16" rx="3" />
        <path d="M8 3v4m8-4v4M3 10h18" />
        <path d="M8 14h.01m4 0h.01m4 0h.01M8 18h.01m4 0h.01" />
      </>
    ),
    book: (
      <>
        <path d="M5 4h11a3 3 0 0 1 3 3v13H7a3 3 0 0 1-3-3V5a1 1 0 0 1 1-1Z" />
        <path d="M7 16h12M8 8h7m-7 4h5" />
      </>
    ),
    settings: (
      <>
        <circle cx="12" cy="12" r="3" />
        <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4V21a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1a1.7 1.7 0 0 0 1.9.3A1.7 1.7 0 0 0 10 3v-.2h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1Z" />
      </>
    ),
    bell: (
      <>
        <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9" />
        <path d="M10 21h4" />
      </>
    ),
    eye: (
      <>
        <path d="M2.5 12s3.5-6 9.5-6 9.5 6 9.5 6-3.5 6-9.5 6-9.5-6-9.5-6Z" />
        <circle cx="12" cy="12" r="2.5" />
      </>
    ),
    arrowUp: (
      <>
        <path d="m6 10 6-6 6 6M12 4v16" />
      </>
    ),
    arrowDown: (
      <>
        <path d="m6 14 6 6 6-6M12 20V4" />
      </>
    ),
    plus: <path d="M12 5v14M5 12h14" />,
    more: (
      <>
        <circle cx="5" cy="12" r="1" fill="currentColor" />
        <circle cx="12" cy="12" r="1" fill="currentColor" />
        <circle cx="19" cy="12" r="1" fill="currentColor" />
      </>
    ),
    check: <path d="m5 12 4 4L19 6" />,
    clock: (
      <>
        <circle cx="12" cy="12" r="9" />
        <path d="M12 7v5l3 2" />
      </>
    ),
    eyeOff: (
      <>
        <path d="M3 3l18 18" />
        <path d="M10.6 6.1A9.5 9.5 0 0 1 12 6c6 0 9.5 6 9.5 6a16 16 0 0 1-3 3.7M6.5 7.6A16 16 0 0 0 2.5 12s3.5 6 9.5 6c1.5 0 2.800-.3 4-.9" />
      </>
    ),
    home: (
      <>
        <path d="m3 11 9-8 9 8" />
        <path d="M5 10v10h14V10M9 20v-6h6v6" />
      </>
    ),
  }
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="1.8"
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {paths[name]}
    </svg>
  )
}

const nav = [
  ["Beranda", "grid"],
  ["Keuangan", "wallet"],
  ["Akademik", "calendar"],
  ["Diari", "book"],
] as const

const tasksSeed = [
  {
    id: 1,
    title: "Revisi proposal skripsi",
    meta: "Metodologi Penelitian",
    due: "Hari ini, 23:59",
    urgent: true,
    done: false,
  },
  {
    id: 2,
    title: "Kuis Mingguan Bab 4",
    meta: "Sistem Informasi",
    due: "Besok, 10:00",
    urgent: false,
    done: false,
  },
  {
    id: 3,
    title: "Baca materi komunikasi",
    meta: "Komunikasi Bisnis",
    due: "18 Jun",
    urgent: false,
    done: true,
  },
]

export default function App({
  user,
  onLogout,
}: {
  user: User
  onLogout: () => void
}) {
  const [active, setActive] = useState("Beranda")
  const [visible, setVisible] = useState(true)
  const [tasks, setTasks] = useState(tasksSeed)
  const [notice, setNotice] = useState("")
  const [modalOpen, setModalOpen] = useState(false)
  const [transactionType, setTransactionType] = useState<"income" | "expense">(
    "expense",
  )
  const [amount, setAmount] = useState("")
  const [account, setAccount] = useState<"cash" | "digital">("cash")
  const [note, setNote] = useState("")
  const [balances, setBalances] = useState({
    cash: 825000,
    digital: 3000000,
    expense: 1475000,
  })

  const pageCopy: Record<string, [string, string]> = {
    Beranda: [
      `Selamat pagi, ${user.name}.`,
      "Semua terkendali. Mari jalani hari dengan tenang.",
    ],
    Keuangan: ["Keuanganmu.", "Pantau saldo dan pengeluaran dari satu tempat."],
    Akademik: ["Agenda akademik.", "Jadwal dan tugas pentingmu hari ini."],
    Diari: ["Ruang kecilmu.", "Catat cerita dan perasaanmu dengan aman."],
  }

  const storeKey = `friendkos:data:${user.id}`
  const hydrated = useRef(false)
  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(storeKey) || "null")
      if (saved) {
        setBalances(saved.balances)
        setTasks(saved.tasks)
      }
    } catch {}
    hydrated.current = true
    if (user.mode === "google") {
      loadCloud(user.id)
        .then((c) => {
          if (c) {
            setBalances(c.balances)
            setTasks(c.tasks)
          }
        })
        .catch(() => {})
    }
  }, [])
  useEffect(() => {
    if (!hydrated.current) return
    const data = { balances, tasks }
    localStorage.setItem(storeKey, JSON.stringify(data))
    if (user.mode === "google") saveCloud(user.id, data).catch(() => {})
  }, [balances, tasks])

  const rupiah = (value: number) => `Rp ${value.toLocaleString("id-ID")}`

  const toast = (message: string) => {
    setNotice(message)
    window.setTimeout(() => setNotice(""), 2200)
  }

  const navigate = (label: string) => {
    setActive(label)
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  const openTransaction = (type: "income" | "expense" = "expense") => {
    setTransactionType(type)
    setModalOpen(true)
  }

  const submitTransaction = (event: React.FormEvent) => {
    event.preventDefault()
    const value = Number(amount.replace(/\D/g, ""))
    if (!value) {
      toast("Masukkan nominal transaksi")
      return
    }
    setBalances((current) => ({
      ...current,
      [account]: Math.max(
        0,
        current[account] + (transactionType === "income" ? value : -value),
      ),
      expense:
        transactionType === "expense"
          ? current.expense + value
          : current.expense,
    }))
    setAmount("")
    setNote("")
    setModalOpen(false)
    toast(
      `${
        transactionType === "income" ? "Pemasukan" : "Pengeluaran"
      } berhasil dicatat`,
    )
  }

  return (
    <div className="app-shell">
      <aside className="sidebar glass">
        <div className="brand">
          <div className="brand-mark">
            <span></span>
            <span></span>
          </div>
          <strong>
            friend<span>kos</span>
          </strong>
        </div>
        <nav className="nav-list" aria-label="Navigasi utama">
          {nav.map(([label, icon]) => (
            <button
              key={label}
              className={active === label ? "nav-item active" : "nav-item"}
              onClick={() => navigate(label)}
            >
              <Icon name={icon} /> <span>{label}</span>
            </button>
          ))}
        </nav>
        <div className="sidebar-bottom">
          <button
            className="nav-item"
            onClick={() => toast("Pengaturan akan segera tersedia")}
          >
            <Icon name="settings" />
            <span>Pengaturan</span>
          </button>
          <div
            className="profile"
            onClick={onLogout}
            role="button"
            tabIndex={0}
            title="Keluar"
          >
            <div className="avatar">{user.name.slice(0, 2).toUpperCase()}</div>
            <div>
              <strong>{user.name}</strong>
              <span>{user.mode === "google" ? "Google" : "Tamu"} · Keluar</span>
            </div>
            <Icon name="more" size={18} />
          </div>
        </div>
      </aside>

      <main>
        <header>
          <div>
            <p className="eyebrow">SENIN, 16 JUNI 2025</p>
            <h1>{pageCopy[active][0]}</h1>
            <p className="subtitle">{pageCopy[active][1]}</p>
          </div>
          <div className="header-actions">
            <button
              className="icon-button"
              aria-label="Notifikasi"
              onClick={() => toast("Tidak ada notifikasi baru")}
            >
              <Icon name="bell" />
            </button>
            <button
              className="primary-button"
              onClick={() => openTransaction()}
            >
              <Icon name="plus" size={18} /> Catat transaksi
            </button>
          </div>
        </header>

        <section className={`dashboard-grid view-${active.toLowerCase()}`}>
          <div className="balance-card glass">
            <div className="balance-top">
              <div>
                <p>Total saldo bulan ini</p>
                <h2>
                  {visible
                    ? rupiah(balances.cash + balances.digital)
                    : "Rp •••••••"}
                </h2>
              </div>
              <button
                className="ghost-icon"
                aria-label={visible ? "Sembunyikan saldo" : "Tampilkan saldo"}
                aria-pressed={!visible}
                onClick={() => setVisible(!visible)}
              >
                <Icon name={visible ? "eye" : "eyeOff"} size={18} />
              </button>
            </div>
            <div className="balance-split">
              <div>
                <span className="ledger-icon cash">
                  <Icon name="wallet" size={17} />
                </span>
                <p>Uang tunai</p>
                <strong>{visible ? rupiah(balances.cash) : "Rp ••••••"}</strong>
              </div>
              <div>
                <span className="ledger-icon digital">
                  <Icon name="home" size={17} />
                </span>
                <p>Rekening & e-wallet</p>
                <strong>
                  {visible ? rupiah(balances.digital) : "Rp ••••••"}
                </strong>
              </div>
            </div>
            <div className="budget-row">
              <span>Pengeluaran bulan ini</span>
              <strong>
                {visible ? rupiah(balances.expense) : "Rp ••••••"}{" "}
                <em>dari {visible ? "Rp 2.500.000" : "Rp ••••••"}</em>
              </strong>
            </div>
            <div className="progress">
              <span></span>
            </div>
          </div>

          <div className="quick-card glass">
            <div className="section-heading">
              <div>
                <p className="eyebrow">AKSES CEPAT</p>
                <h3>Butuh apa sekarang?</h3>
              </div>
            </div>
            <div className="quick-actions">
              <button onClick={() => openTransaction("income")}>
                <span className="quick-icon income">
                  <Icon name="arrowDown" />
                </span>
                <strong>Pemasukan</strong>
                <small>Catat uang masuk</small>
              </button>
              <button onClick={() => openTransaction("expense")}>
                <span className="quick-icon expense">
                  <Icon name="arrowUp" />
                </span>
                <strong>Pengeluaran</strong>
                <small>Catat uang keluar</small>
              </button>
              <button onClick={() => navigate("Diari")}>
                <span className="quick-icon diary">
                  <Icon name="book" />
                </span>
                <strong>Tulis diari</strong>
                <small>Simpan cerita hari ini</small>
              </button>
            </div>
          </div>

          <div className="schedule-card glass">
            <div className="section-heading">
              <div>
                <p className="eyebrow">JADWAL HARI INI</p>
                <h3>2 kelas menantimu</h3>
              </div>
              <button onClick={() => navigate("Akademik")}>
                Lihat kalender
              </button>
            </div>
            <div className="timeline">
              <div className="time">
                <strong>08:00</strong>
                <span>09:40</span>
              </div>
              <div className="line">
                <i></i>
              </div>
              <div className="class-card cyan">
                <div>
                  <small>RUANG B.204</small>
                  <strong>Interaksi Manusia & Komputer</strong>
                  <span>Dr. Andini Putri, M.Kom.</span>
                </div>
                <span className="status">30 menit lagi</span>
              </div>
              <div className="time">
                <strong>13:00</strong>
                <span>14:40</span>
              </div>
              <div className="line muted">
                <i></i>
              </div>
              <div className="class-card">
                <div>
                  <small>LAB KOMPUTER 3</small>
                  <strong>Basis Data Lanjut</strong>
                  <span>Bapak Hendra Wijaya</span>
                </div>
                <span className="room">Lantai 3</span>
              </div>
            </div>
          </div>

          <div className="tasks-card glass">
            <div className="section-heading">
              <div>
                <p className="eyebrow">PRIORITAS</p>
                <h3>Tugas terdekat</h3>
              </div>
              <span className="counter">
                {tasks.filter((t) => !t.done).length} tersisa
              </span>
            </div>
            <div className="task-list">
              {tasks.map((task) => (
                <div className={task.done ? "task done" : "task"} key={task.id}>
                  <button
                    className="checkbox"
                    aria-label={`Tandai ${task.title}`}
                    onClick={() =>
                      setTasks(
                        tasks.map((t) =>
                          t.id === task.id ? { ...t, done: !t.done } : t,
                        ),
                      )
                    }
                  >
                    {task.done && <Icon name="check" size={14} />}
                  </button>
                  <div className="task-copy">
                    <strong>{task.title}</strong>
                    <span>{task.meta}</span>
                  </div>
                  <span className={task.urgent ? "due urgent" : "due"}>
                    <Icon name="clock" size={14} />
                    {task.due}
                  </span>
                </div>
              ))}
            </div>
            <button
              className="text-button"
              onClick={() => toast("Halaman semua tugas")}
            >
              Lihat semua tugas <span>→</span>
            </button>
          </div>

          <div className="diary-card glass">
            <div className="section-heading">
              <div>
                <p className="eyebrow">CATATAN TERBARU</p>
                <h3>Ruang kecilmu</h3>
              </div>
              <button className="ghost-icon">
                <Icon name="more" size={18} />
              </button>
            </div>
            <div className="diary-entry">
              <div className="diary-date">
                <strong>15</strong>
                <span>JUN</span>
              </div>
              <div>
                <strong>Hari yang cukup panjang.</strong>
                <p>
                  Akhirnya tugas kelompok selesai juga. Ternyata ngobrol
                  baik-baik selalu jadi jalan keluar...
                </p>
                <div className="mood">
                  <span>lega</span>
                  <span>produktif</span>
                </div>
              </div>
            </div>
            <div className="offline">
              <i></i> Tersimpan aman di perangkatmu
            </div>
          </div>
        </section>
      </main>

      <nav className="mobile-nav glass" aria-label="Navigasi seluler">
        {nav.map(([label, icon]) => (
          <button
            key={label}
            className={active === label ? "active" : ""}
            onClick={() => navigate(label)}
          >
            <Icon name={icon} />
            <span>{label}</span>
          </button>
        ))}
      </nav>
      {modalOpen && (
        <div
          className="modal-backdrop"
          role="presentation"
          onMouseDown={() => setModalOpen(false)}
        >
          <div
            className="transaction-modal glass"
            role="dialog"
            aria-modal="true"
            aria-labelledby="transaction-title"
            onMouseDown={(event) => event.stopPropagation()}
          >
            <div className="modal-heading">
              <div>
                <p className="eyebrow">TRANSAKSI BARU</p>
                <h2 id="transaction-title">
                  {transactionType === "income"
                    ? "Catat pemasukan"
                    : "Catat pengeluaran"}
                </h2>
              </div>
              <button
                className="modal-close"
                aria-label="Tutup"
                onClick={() => setModalOpen(false)}
              >
                ×
              </button>
            </div>
            <div className="type-switch">
              <button
                className={transactionType === "expense" ? "active" : ""}
                onClick={() => setTransactionType("expense")}
              >
                Pengeluaran
              </button>
              <button
                className={transactionType === "income" ? "active" : ""}
                onClick={() => setTransactionType("income")}
              >
                Pemasukan
              </button>
            </div>
            <form onSubmit={submitTransaction}>
              <label>
                Nominal
                <div className="amount-input">
                  <span>Rp</span>
                  <input
                    autoFocus
                    inputMode="numeric"
                    placeholder="0"
                    value={amount}
                    onChange={(event) =>
                      setAmount(event.target.value.replace(/\D/g, ""))
                    }
                  />
                </div>
              </label>
              <label>
                Sumber dana
                <select
                  value={account}
                  onChange={(event) =>
                    setAccount(event.target.value as "cash" | "digital")
                  }
                >
                  <option value="cash">Uang tunai</option>
                  <option value="digital">Rekening & e-wallet</option>
                </select>
              </label>
              <label>
                Catatan
                <input
                  placeholder="Contoh: makan siang"
                  value={note}
                  onChange={(event) => setNote(event.target.value)}
                />
              </label>
              <button className="primary-button modal-submit" type="submit">
                <Icon name="plus" size={18} /> Simpan transaksi
              </button>
            </form>
          </div>
        </div>
      )}
      {notice && <div className="toast">{notice}</div>}
    </div>
  )
}
