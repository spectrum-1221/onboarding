-- Jadwal Training Zahir — skema Supabase
-- Jalankan sekali di: Supabase Dashboard > SQL Editor > New query > tempel seluruh isi file ini > Run.
-- Aman dijalankan ulang (pakai "if not exists"/"or replace"), kecuali bagian "create policy" di bawah
-- yang perlu di-drop dulu kalau mau mengubah daftar email staf.

create extension if not exists pgcrypto;

-- Tiga tabel, masing-masing menyimpan satu dokumen sebagai JSON di kolom "data" (mirip koleksi
-- Firestore), supaya field baru di aplikasi tidak perlu ubah skema tabel.
create table if not exists "trainings" (
  id text primary key,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists "beritaAcaras" (
  id text primary key,
  data jsonb not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Salinan Berita Acara yang sudah dikirim ke klien, diberi token acak sebagai ID (dibuat aplikasi
-- saat tombol "Kirim ke Klien" ditekan). Klien tanpa login hanya boleh membuka dan menyetujui
-- lewat dua fungsi get_ba_share/approve_ba_share di bawah, tidak langsung ke tabel ini.
create table if not exists "baShare" (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table "trainings" enable row level security;
alter table "beritaAcaras" enable row level security;
alter table "baShare" enable row level security;

-- Daftar email staf yang boleh login dan mengelola data. Tambahkan/ganti email di sini bila perlu.
create or replace function is_staff() returns boolean
language sql stable as $$
  select coalesce(auth.jwt() ->> 'email', '') in (
    'onboarding.zahirtrainer@gmail.com',
    'sigitprasetiyo123@gmail.com'
  );
$$;

drop policy if exists "staff full access" on "trainings";
drop policy if exists "staff full access" on "beritaAcaras";
drop policy if exists "staff full access" on "baShare";
create policy "staff full access" on "trainings" for all using (is_staff()) with check (is_staff());
create policy "staff full access" on "beritaAcaras" for all using (is_staff()) with check (is_staff());
create policy "staff full access" on "baShare" for all using (is_staff()) with check (is_staff());

-- updated_at terisi otomatis setiap baris diubah.
create or replace function set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;
drop trigger if exists trg_trainings_updated on "trainings";
drop trigger if exists trg_ba_updated on "beritaAcaras";
drop trigger if exists trg_share_updated on "baShare";
create trigger trg_trainings_updated before update on "trainings" for each row execute function set_updated_at();
create trigger trg_ba_updated before update on "beritaAcaras" for each row execute function set_updated_at();
create trigger trg_share_updated before update on "baShare" for each row execute function set_updated_at();

-- Halaman persetujuan klien (tanpa login) hanya boleh: (1) membaca satu dokumen lewat tokennya
-- sendiri, (2) mengubah status dari "sent" menjadi "approved". SECURITY DEFINER artinya fungsi ini
-- jalan dengan hak pemiliknya (bukan hak pemanggil), jadi bisa baca/ubah tabel "baShare" walau
-- RLS di atas tidak mengizinkan publik mengakses tabel itu langsung.
create or replace function get_ba_share(p_token text)
returns table(id text, data jsonb)
language sql security definer set search_path = public as $$
  select id, data from "baShare" where id = p_token;
$$;
grant execute on function get_ba_share(text) to anon, authenticated;

create or replace function approve_ba_share(p_token text, p_approved_by text)
returns void
language plpgsql security definer set search_path = public as $$
declare v_now text := to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"');
begin
  if p_approved_by is null or length(btrim(p_approved_by)) = 0 or length(p_approved_by) > 100 then
    raise exception 'Nama penyetuju tidak valid';
  end if;
  update "baShare"
  set data = data || jsonb_build_object('status', 'approved', 'approvedAt', v_now, 'approvedBy', btrim(p_approved_by))
  where id = p_token and data ->> 'status' = 'sent';
  if not found then
    raise exception 'Dokumen tidak ditemukan atau sudah tidak bisa disetujui';
  end if;
end;
$$;
grant execute on function approve_ba_share(text, text) to anon, authenticated;

-- Dipanggil sekali oleh halaman klien saat dokumen pertama kali dibuka, untuk mengisi "Dilihat Klien"
-- di riwayat status. Diam-diam tidak melakukan apa pun kalau sudah pernah dilihat atau sudah disetujui.
create or replace function mark_ba_share_viewed(p_token text)
returns void
language plpgsql security definer set search_path = public as $$
begin
  update "baShare"
  set data = data || jsonb_build_object('viewedAt', to_char(now() at time zone 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'))
  where id = p_token and data ->> 'status' = 'sent' and (data ->> 'viewedAt') is null;
end;
$$;
grant execute on function mark_ba_share_viewed(text) to anon, authenticated;

-- Supaya layar yang terbuka ikut update otomatis saat ada perubahan (seperti Firestore onSnapshot).
-- "baShare" aman ikut disiarkan: anon/publik tetap tidak punya izin SELECT di tabel ini (lihat RLS
-- di atas), jadi perubahan hanya diterima oleh sesi staf yang sudah login.
alter publication supabase_realtime add table "trainings", "beritaAcaras", "baShare";
