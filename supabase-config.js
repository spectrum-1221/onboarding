// Konfigurasi project Supabase.
// Bukan rahasia; "anon key" ini memang dipakai di browser dan yang melindungi data
// adalah Row Level Security (RLS) yang dibuat lewat supabase-schema.sql, bukan kerahasiaan key ini.
// Isi null/kosong untuk kembali ke mode browser (login sementara, data di localStorage).
window.SUPABASE_CONFIG = {
  url: null, // contoh: "https://xxxxxxxxxxxx.supabase.co"
  anonKey: null // Project Settings > API > "anon public"
};
