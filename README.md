# Jadwal Training Zahir

Aplikasi pencatatan jadwal training Zahir ke client. Tanpa build: pasang di hosting statis (Vercel, GitHub Pages) atau jalankan lokal dengan `python -m http.server 8000` lalu buka `http://localhost:8000`. Mode Firebase tidak jalan bila `index.html` dibuka langsung dari folder (`file://`).

Data yang dicatat: nama perusahaan, trainer, tanggal, jam, versi Zahir, lama training, alamat, kontak person client (nama dan telepon), dan biaya transport.

## Mode penyimpanan

- **Firebase terisi** (`firebase-config.js` berisi konfigurasi): login memakai Firebase Authentication (email dan password) dan data disimpan di Firestore koleksi `trainings`, dibagi ke semua pengguna.
- **Firebase kosong** (`window.FIREBASE_CONFIG = null`): login sementara di dalam kode dan data hanya di browser yang dipakai (localStorage).

## Menyambungkan ke Firebase

1. Buka https://console.firebase.google.com, buat project baru (disarankan terpisah dari `zahir-plugin` supaya aturan Firestore aplikasi lain tidak tertimpa).
2. **Build > Firestore Database > Create database.** Pilih lokasi `asia-southeast2` (Jakarta) bila tersedia.
3. **Build > Authentication > Get started > Sign-in method > Email/Password > Enable.**
4. **Authentication > Users > Add user.** Buat pengguna, misalnya `onboarding.zahirtrainer@gmail.com` dengan password pilihan Anda (minimal 6 karakter).
5. **Firestore Database > Rules.** Tempel isi `firestore.rules`, sesuaikan daftar email, lalu **Publish**.
6. **Project settings > General > Your apps > tombol `</>` (Web).** Daftarkan app, lalu salin objek `firebaseConfig` ke `firebase-config.js`.
7. **Authentication > Settings > Authorized domains.** Tambahkan domain tempat aplikasi dipasang (misalnya `nama-app.vercel.app`). `localhost` sudah ada.
8. Commit dan push perubahan `firebase-config.js`, lalu buka aplikasi dan masuk dengan pengguna dari langkah 4.

Jadwal yang sebelumnya tersimpan di localStorage browser tidak ikut pindah ke Firestore.

## Berita Acara dan persetujuan klien

Di mode Firebase, tombol **Kirim ke Klien** pada detail Berita Acara membuat link `...#/setuju/<token>`. Link bisa disalin atau dikirim lewat WhatsApp dan email ke PIC. Klien membuka link tanpa login, membaca dokumen, lalu menekan **Setujui**. Status, nama penyetuju, serta stempel APPROVED dengan tanggal dan jam terisi otomatis di dokumen dan di aplikasi.

Salinan dokumen disimpan di koleksi `baShare` dengan token acak 24 karakter sebagai ID. Siapa pun yang memegang link bisa membuka dokumen itu, tetapi tidak bisa mendaftar dokumen lain. Klien hanya boleh mengubah status dari `sent` ke `approved`.

**Wajib:** setelah memperbarui kode, tempel ulang isi `firestore.rules` di Firestore Database > Rules lalu **Publish**. Tanpa itu, tombol Kirim ke Klien gagal dan klien tidak bisa membuka link. Di mode tanpa Firebase (localStorage), fitur link klien tidak tersedia.
