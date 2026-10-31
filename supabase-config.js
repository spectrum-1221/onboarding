// Konfigurasi project Supabase.
// Bukan rahasia; "anon key" ini memang dipakai di browser dan yang melindungi data
// adalah Row Level Security (RLS) yang dibuat lewat supabase-schema.sql, bukan kerahasiaan key ini.
// Isi null/kosong untuk kembali ke mode browser (login sementara, data di localStorage).
window.SUPABASE_CONFIG = {
  url: "https://rljmqkrpopqkgysntyit.supabase.co",
  anonKey: "sb_publishable__dI08knguGwBlFyRDfYD0w_6rL_ZC0e"
};
