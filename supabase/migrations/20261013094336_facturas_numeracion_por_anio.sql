-- Numeración de facturas por año (2026/001, 2026/002...), sin huecos.
--
-- El contador vive en `series_facturas` y se incrementa en el mismo
-- INSERT de la factura: si el alta falla, el contador vuelve atrás con la
-- transacción (una secuencia de Postgres no, y dejaba huecos). La fila del
-- contador queda bloqueada durante el alta, así que dos altas a la vez no
-- pueden coger el mismo número.

-- 1. Dueño, año y número de orden en cada factura.
alter table public.facturas
  add column owner_id uuid references auth.users(id) on delete cascade,
  add column anio int,
  add column secuencia int;

-- Las 3 facturas existentes conservan su número ("1", "2", "3"); solo se
-- rellenan los campos nuevos para que la serie de 2026 siga en el 004.
update public.facturas f
set owner_id = c.owner_id,
    anio = extract(year from f.fecha)::int,
    secuencia = f.numero::int
from public.clientes c
where c.id = f.cliente_id;

alter table public.facturas
  alter column owner_id set not null,
  alter column owner_id set default auth.uid(),
  alter column anio set not null,
  alter column secuencia set not null,
  alter column numero drop default;

-- Unicidad por usuario (antes era global, y con más de un usuario dos
-- "2026/001" chocarían).
alter table public.facturas
  drop constraint facturas_numero_key,
  add constraint facturas_owner_numero_key unique (owner_id, numero),
  add constraint facturas_owner_anio_secuencia_key unique (owner_id, anio, secuencia);

drop sequence public.facturas_numero_seq;

-- 2. Contador por usuario y año, con RLS desde el primer momento.
create table public.series_facturas (
  owner_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  anio int not null,
  ultimo int not null,
  primary key (owner_id, anio)
);

alter table public.series_facturas enable row level security;

create policy series_facturas_owner_all on public.series_facturas
  for all
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

insert into public.series_facturas (owner_id, anio, ultimo)
select owner_id, anio, max(secuencia)
from public.facturas
group by owner_id, anio;

-- 3. Asignar número al dar de alta.
create function public.asignar_numero_factura()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  siguiente int;
begin
  select c.owner_id into new.owner_id
  from public.clientes c
  where c.id = new.cliente_id;

  new.anio := extract(year from new.fecha)::int;

  insert into public.series_facturas as s (owner_id, anio, ultimo)
  values (new.owner_id, new.anio, 1)
  on conflict (owner_id, anio) do update set ultimo = s.ultimo + 1
  returning s.ultimo into siguiente;

  new.secuencia := siguiente;
  new.numero := new.anio || '/' || lpad(siguiente::text, 3, '0');
  return new;
end;
$$;

create trigger facturas_asignar_numero
  before insert on public.facturas
  for each row execute function public.asignar_numero_factura();

-- 4. Una factura emitida no cambia de número, dueño ni serie al editarla
--    (aunque se cambie su fecha a otro año).
create function public.proteger_numero_factura()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.owner_id := old.owner_id;
  new.anio := old.anio;
  new.secuencia := old.secuencia;
  new.numero := old.numero;
  return new;
end;
$$;

create trigger facturas_proteger_numero
  before update on public.facturas
  for each row execute function public.proteger_numero_factura();
