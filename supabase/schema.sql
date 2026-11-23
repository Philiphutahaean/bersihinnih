-- Bersihinnih (BRH) starter schema for Supabase Postgres
create extension if not exists pgcrypto;

create type public.order_status as enum (
  'booking_received',
  'inspection_pending',
  'price_approval',
  'cleaning',
  'ready',
  'completed',
  'cancelled'
);

create table if not exists public.services (
  id text primary key,
  name text not null,
  description text,
  base_price integer not null check (base_price >= 0),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.services (id,name,description,base_price) values
 ('shoe','Deep Cleaning Sepatu','Pembersihan dan perawatan sepatu.',30000),
 ('helmet','Deep Cleaning Helm','Pembersihan bagian luar dan dalam helm.',30000)
on conflict (id) do nothing;

create table if not exists public.customer_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  booking_code text not null unique,
  customer_id uuid references auth.users(id) on delete set null,
  customer_name text not null,
  customer_phone text not null,
  service_id text not null references public.services(id),
  fulfillment text not null check (fulfillment in ('dropoff','pickup')),
  pickup_address text,
  handover_date date not null,
  handover_window text not null,
  item_condition text not null,
  customer_notes text,
  payment_preference text not null default 'cash' check (payment_preference in ('cash','transfer')),
  estimate_amount integer not null check (estimate_amount >= 0),
  final_amount integer check (final_amount is null or final_amount >= 0),
  status public.order_status not null default 'booking_received',
  price_approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.order_status_events (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders(id) on delete cascade,
  status public.order_status not null,
  note text,
  actor_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  code text unique,
  name text not null,
  discount_amount integer not null default 0 check (discount_amount >= 0),
  active boolean not null default false,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists orders_customer_id_idx on public.orders(customer_id);
create index if not exists orders_phone_idx on public.orders(customer_phone);
create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists order_status_events_order_idx on public.order_status_events(order_id, created_at desc);

alter table public.services enable row level security;
alter table public.customer_profiles enable row level security;
alter table public.orders enable row level security;
alter table public.order_status_events enable row level security;
alter table public.promotions enable row level security;

-- Public customers may read active services and active promotions only.
create policy "active services are public" on public.services for select using (active);
create policy "active promotions are public" on public.promotions for select using (active);

-- Customers may read/update their own profile and view their own orders.
create policy "customers read own profile" on public.customer_profiles for select to authenticated using (auth.uid() = id);
create policy "customers update own profile" on public.customer_profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "customers read own orders" on public.orders for select to authenticated using (auth.uid() = customer_id);
create policy "customers read own order events" on public.order_status_events for select to authenticated using (
  exists (select 1 from public.orders o where o.id = order_id and o.customer_id = auth.uid())
);

-- Do not add anonymous INSERT/UPDATE policies for orders or admin tables.
-- Create orders and change statuses through a trusted server route using the Supabase service role key.
-- Never expose SUPABASE_SERVICE_ROLE_KEY in browser code.
