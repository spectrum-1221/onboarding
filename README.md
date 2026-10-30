# Jadwal Training Zahir

Aplikasi pencatatan jadwal training Zahir ke client. Tanpa build: pasang di hosting statis (Vercel, GitHub Pages) atau jalankan lokal dengan `python -m http.server 8000` lalu buka `http://localhost:8000`. Mode Supabase tidak jalan bila `index.html` dibuka langsung dari folder (`file://`).

Data yang dicatat: nama perusahaan, trainer, tanggal, jam, versi Zahir, lama training, alamat, kontak person client (nama dan telepon), dan biaya transport.

## Mode penyimpanan

- **Supabase terisi** (`supabase-config.js` berisi `url` dan `anonKey`): login memakai Supabase Authentication (email dan password) dan data disimpan di Supabase, dibagi ke semua pengguna.
- **Supabase kosong** (`url`/`anonKey` bernilai `null`): login sementara di dalam kode dan data hanya di browser yang dipakai (localStorage).

## Menyambungkan ke Supabase

1. Buka https://supabase.com/dashboard, buat project baru (pilih region Singapore kalau tersedia, paling dekat dengan Indonesia).
2. **SQL Editor > New query.** Tempel seluruh isi `supabase-schema.sql`, lalu **Run**. Ini membuat tabel `trainings`, `beritaAcaras`, `baShare`, aturan keamanan (Row Level Security), dan dua fungsi untuk halaman persetujuan klien.
3. **Authentication > Sign In / Providers > Email.** Pastikan Email aktif (biasanya sudah aktif secara bawaan). Di **Authentication > Sign In / Providers > Email**, matikan "Confirm email" supaya pengguna yang Anda buat manual bisa langsung login tanpa verifikasi.
4. **Authentication > Users > Add user > Create new user.** Buat pengguna, misalnya `onboarding.zahirtrainer@gmail.com` dengan password pilihan Anda (minimal 6 karakter), centang **Auto Confirm User**.
5. Kalau ada email staf lain yang perlu login, tambahkan juga sebagai user di langkah 4, lalu tambahkan emailnya ke daftar di dalam fungsi `is_staff()` pada `supabase-schema.sql` dan jalankan ulang file itu (bagian `create policy` butuh di-drop dulu — file ini sudah menangani itu sendiri).
6. **Project Settings > API.** Salin **Project URL** dan key **anon public** ke `supabase-config.js`.
7. Commit dan push perubahan `supabase-config.js`, lalu buka aplikasi dan masuk dengan pengguna dari langkah 4.

**Catatan keamanan:** `anonKey` di `supabase-config.js` memang dipakai di browser dan bukan rahasia — ini bukan password. Yang melindungi data adalah Row Level Security di `supabase-schema.sql` (hanya email di `is_staff()` yang boleh baca/tulis), bukan kerahasiaan key ini.

### Pindah dari versi Firebase lama

Kalau sebelumnya aplikasi ini memakai Firebase dan sudah ada data di sana, jalankan `migrate-to-supabase.html` **satu kali saja** setelah langkah 1–2 di atas selesai (tabelnya sudah ada di Supabase, baik `supabase-config.js` sudah diisi atau belum): buka file itu langsung dari komputer, login dengan akun Firebase lama, isi Project URL dan **Service Role Key** Supabase (di **Project Settings > API > service_role**, bukan `anon`), lalu jalankan migrasinya. Baca peringatan di halaman itu sebelum memakainya, dan hapus file itu dari repo setelah selesai.

## Berita Acara dan persetujuan klien

Di mode Supabase, tombol **Kirim ke Klien** pada detail Berita Acara membuat link `...#/setuju/<token>`. Link bisa disalin atau dikirim lewat WhatsApp dan email ke PIC. Klien membuka link tanpa login, membaca dokumen, lalu menekan **Setujui**. Status, nama penyetuju, serta stempel APPROVED dengan tanggal dan jam terisi otomatis di dokumen dan di aplikasi (halaman klien memeriksa status setiap beberapa detik, bukan langsung real-time).

Salinan dokumen disimpan di tabel `baShare` dengan token acak 24 karakter sebagai ID. Siapa pun yang memegang link bisa membuka dokumen itu lewat fungsi khusus di database, tetapi tidak bisa mendaftar atau membuka dokumen lain. Klien hanya boleh mengubah status dari `sent` ke `approved`, juga lewat fungsi khusus itu — bukan akses langsung ke tabel.

**Wajib:** setelah mengubah daftar email staf atau struktur data, jalankan ulang `supabase-schema.sql` di SQL Editor. Di mode tanpa Supabase (localStorage), fitur link klien tidak tersedia.
