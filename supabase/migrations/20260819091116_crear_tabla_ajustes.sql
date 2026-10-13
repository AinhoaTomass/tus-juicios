create table public.ajustes (
  owner_id uuid primary key references auth.users (id) default auth.uid(),
  tema_modo text not null default 'system' check (tema_modo in ('system', 'light', 'dark')),
  despacho_nombre text not null default '',
  despacho_nif_cif text not null default '',
  despacho_direccion text not null default '',
  recordatorios_citas_activo boolean not null default true,
  recordatorios_citas_dias_antes integer not null default 1,
  recordatorios_citas_hora integer not null default 20,
  recordatorios_procedimientos_activo boolean not null default true,
  recordatorios_procedimientos_dias_antes integer not null default 3,
  recordatorios_procedimientos_hora integer not null default 9,
  created_at timestamptz not null default now()
);

alter table public.ajustes enable row level security;

create policy "ajustes_select_own" on public.ajustes
  for select using (owner_id = auth.uid());

create policy "ajustes_insert_own" on public.ajustes
  for insert with check (owner_id = auth.uid());

create policy "ajustes_update_own" on public.ajustes
  for update using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "ajustes_delete_own" on public.ajustes
  for delete using (owner_id = auth.uid());
