create extension if not exists "pgcrypto";

-- Clientes
create table public.clientes (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre text not null,
  nif_cif text,
  tipo text not null check (tipo in ('fisica','juridica')),
  estado text not null default 'activo' check (estado in ('activo','pendiente','cerrado')),
  telefono text,
  email text,
  direccion text,
  resumen text,
  fecha_vencimiento date,
  notas text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index clientes_owner_id_idx on public.clientes(owner_id);
create index clientes_fecha_vencimiento_idx on public.clientes(fecha_vencimiento);

-- Procedimientos
create table public.procedimientos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  nombre text not null,
  estado text not null default 'activo' check (estado in ('activo','pendiente','cerrado')),
  fecha_meta date,
  created_at timestamptz not null default now()
);
create index procedimientos_cliente_id_idx on public.procedimientos(cliente_id);
create index procedimientos_fecha_meta_idx on public.procedimientos(fecha_meta);

-- Documentos
create table public.documentos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  nombre_archivo text not null,
  storage_path text,
  fecha_subida timestamptz not null default now()
);
create index documentos_cliente_id_idx on public.documentos(cliente_id);

-- Eventos
create table public.eventos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  tipo text not null check (tipo in ('Juicio','SMAC','Conciliacion')),
  fecha date not null,
  hora time,
  descripcion text,
  created_at timestamptz not null default now()
);
create index eventos_cliente_id_idx on public.eventos(cliente_id);
create index eventos_fecha_idx on public.eventos(fecha);

-- Rentas
create table public.rentas (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  ejercicio int not null,
  estado text not null default 'en_curso' check (estado in ('en_curso','presentada','pendiente_datos')),
  resultado text,
  fecha date,
  created_at timestamptz not null default now()
);
create index rentas_cliente_id_idx on public.rentas(cliente_id);

-- Facturas
create table public.facturas (
  id uuid primary key default gen_random_uuid(),
  numero text not null unique,
  cliente_id uuid not null references public.clientes(id) on delete cascade,
  concepto text,
  importe numeric(10,2) not null default 0,
  estado text not null default 'pendiente' check (estado in ('pendiente','pagada','vencida')),
  fecha date not null default current_date,
  created_at timestamptz not null default now()
);
create index facturas_cliente_id_idx on public.facturas(cliente_id);

-- Notas (nivel despacho, no ligadas a cliente)
create table public.notas (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  fecha timestamptz not null default now(),
  titulo text not null,
  contenido text,
  created_at timestamptz not null default now()
);
create index notas_owner_id_idx on public.notas(owner_id);

-- RLS
alter table public.clientes enable row level security;
alter table public.procedimientos enable row level security;
alter table public.documentos enable row level security;
alter table public.eventos enable row level security;
alter table public.rentas enable row level security;
alter table public.facturas enable row level security;
alter table public.notas enable row level security;

create policy "clientes_owner_all" on public.clientes
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "notas_owner_all" on public.notas
  for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "procedimientos_owner_all" on public.procedimientos
  for all using (exists (select 1 from public.clientes c where c.id = procedimientos.cliente_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.clientes c where c.id = procedimientos.cliente_id and c.owner_id = auth.uid()));

create policy "documentos_owner_all" on public.documentos
  for all using (exists (select 1 from public.clientes c where c.id = documentos.cliente_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.clientes c where c.id = documentos.cliente_id and c.owner_id = auth.uid()));

create policy "eventos_owner_all" on public.eventos
  for all using (exists (select 1 from public.clientes c where c.id = eventos.cliente_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.clientes c where c.id = eventos.cliente_id and c.owner_id = auth.uid()));

create policy "rentas_owner_all" on public.rentas
  for all using (exists (select 1 from public.clientes c where c.id = rentas.cliente_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.clientes c where c.id = rentas.cliente_id and c.owner_id = auth.uid()));

create policy "facturas_owner_all" on public.facturas
  for all using (exists (select 1 from public.clientes c where c.id = facturas.cliente_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.clientes c where c.id = facturas.cliente_id and c.owner_id = auth.uid()));
