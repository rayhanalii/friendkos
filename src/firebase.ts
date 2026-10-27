import { initializeApp } from "firebase/app"
import {
  GoogleAuthProvider,
  getAuth,
  onAuthStateChanged,
  signInWithPopup,
  signOut,
} from "firebase/auth"
import {
  doc,
  getDoc,
  initializeFirestore,
  persistentLocalCache,
  setDoc,
} from "firebase/firestore"

const env = import.meta.env
const config = {
  apiKey: env.VITE_FIREBASE_API_KEY,
  authDomain: env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: env.VITE_FIREBASE_APP_ID,
}

export const firebaseReady = Boolean(
  config.apiKey && config.projectId && config.appId,
)

const app = firebaseReady ? initializeApp(config) : null
export const auth = app ? getAuth(app) : null
// Firestore dengan cache lokal persisten: data tetap tersedia offline dan sinkron saat online.
const db = app
  ? initializeFirestore(app, { localCache: persistentLocalCache() })
  : null

export const loginWithGoogle = async () => {
  if (!auth) throw new Error("Firebase belum dikonfigurasi")
  return (await signInWithPopup(auth, new GoogleAuthProvider())).user
}
export const logoutFirebase = () => (auth ? signOut(auth) : Promise.resolve())
export const watchAuth = (cb: Parameters<typeof onAuthStateChanged>[1]) =>
  auth ? onAuthStateChanged(auth, cb) : () => {}

export const saveCloud = async (uid: string, data: unknown) => {
  if (db)
    await setDoc(doc(db, "users", uid), {
      data: JSON.stringify(data),
      updatedAt: Date.now(),
    })
}
export const loadCloud = async (uid: string) => {
  if (!db) return null
  const snap = await getDoc(doc(db, "users", uid))
  return snap.exists() ? JSON.parse(snap.data().data) : null
}
