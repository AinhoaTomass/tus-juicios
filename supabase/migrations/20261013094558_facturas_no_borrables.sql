-- Las facturas emitidas no se borran: deben conservarse y su numeración
-- no puede tener huecos. Si una está mal, se emite una rectificativa.

-- 1. RLS: la política "ALL" se sustituye por lectura, alta y edición; sin
--    política de DELETE, la app no puede borrar ninguna factura.
drop policy facturas_owner_all on public.facturas;

create policy facturas_owner_select on public.facturas
  for select
  using (exists (select 1 from public.clientes c
                 where c.id = facturas.cliente_id and c.owner_id = (select auth.uid())));

create policy facturas_owner_insert on public.facturas
  for insert
  with check (exists (select 1 from public.clientes c
                      where c.id = facturas.cliente_id and c.owner_id = (select auth.uid())));

create policy facturas_owner_update on public.facturas
  for update
  using (exists (select 1 from public.clientes c
                 where c.id = facturas.cliente_id and c.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.clientes c
                      where c.id = facturas.cliente_id and c.owner_id = (select auth.uid())));

-- 2. Trigger: además de la RLS (que solo ignora el borrado en silencio),
--    rechaza cualquier DELETE con un error claro, también desde el panel
--    de Supabase o con la clave de servicio.
create function public.impedir_borrar_factura()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'Las facturas emitidas no se pueden eliminar (factura %). Emite una factura rectificativa.', old.numero
    using errcode = 'P0001';
end;
$$;

create trigger facturas_impedir_borrado
  before delete on public.facturas
  for each row execute function public.impedir_borrar_factura();
