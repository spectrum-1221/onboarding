// Isi dengan konfigurasi web app dari Firebase Console:
// Project settings > General > Your apps > Web app > SDK setup and configuration > Config.
// Selama nilainya null, aplikasi memakai login sementara dan menyimpan data di browser (localStorage).
// Konfigurasi web Firebase bukan rahasia; yang melindungi data adalah aturan di firestore.rules.
window.FIREBASE_CONFIG = null;

/* Contoh setelah diisi:
window.FIREBASE_CONFIG = {
  apiKey: "AIza...",
  authDomain: "nama-project.firebaseapp.com",
  projectId: "nama-project",
  storageBucket: "nama-project.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abcdef123456"
};
*/
