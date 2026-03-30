-- Supabase SQL Editor'a yapıştırıp çalıştırın

-- Admins Table (Özel Yönetici Tablosu)
create table admins (
  id uuid default gen_random_uuid() primary key,
  username text not null unique,
  password text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- İlk varsayılan yöneticiyi ekle
insert into admins (username, password) values ('admin', '123');

-- Categories Table
create table categories (
  id uuid default gen_random_uuid() primary key,
  name text not null unique,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Menu Items Table
create table menu_items (
  id text primary key,
  name text not null,
  description text,
  price numeric not null,
  category text not null references categories(name) on delete cascade on update cascade,
  image text,
  popular boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Orders Table
create table orders (
  id text primary key,
  table_number text not null,
  items jsonb not null,
  total numeric not null,
  status text not null default 'Yeni',
  timestamp bigint not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS'yi aktifleştiriyoruz ve herkese açık erişim veriyoruz (Çünkü özel bir admin tablosu kullanıyoruz)
alter table categories enable row level security;
alter table menu_items enable row level security;
alter table orders enable row level security;
alter table admins enable row level security;

-- Herkesin okuma ve yazma yapabilmesi için kurallar (Anonim erişim)
create policy "Public Access" on categories for all using (true) with check (true);
create policy "Public Access" on menu_items for all using (true) with check (true);
create policy "Public Access" on orders for all using (true) with check (true);
create policy "Public Access" on admins for all using (true) with check (true);

-- Realtime'ı aktifleştir (Orders, Menu Items ve Categories tabloları için)
alter publication supabase_realtime add table orders;
alter publication supabase_realtime add table menu_items;
alter publication supabase_realtime add table categories;

-- Storage Bucket Oluşturma (Görseller için)
insert into storage.buckets (id, name, public) values ('menu-images', 'menu-images', true) on conflict do nothing;

-- Storage için RLS Kuralları (Herkes okuyabilir ve yükleyebilir)
create policy "Public Access" on storage.objects for select using ( bucket_id = 'menu-images' );
create policy "Anyone can upload" on storage.objects for insert with check ( bucket_id = 'menu-images' );
create policy "Anyone can update" on storage.objects for update with check ( bucket_id = 'menu-images' );
create policy "Anyone can delete" on storage.objects for delete using ( bucket_id = 'menu-images' );
