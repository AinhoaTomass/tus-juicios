-- Rendimiento: las políticas RLS evaluaban auth.uid() una vez por fila.
-- Envuelto en (select auth.uid()) Postgres lo calcula una sola vez por
-- consulta. Las reglas son exactamente las mismas que antes.

drop policy clientes_owner_all on public.clientes;
create policy clientes_owner_all on public.clientes
  for all
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy notas_owner_all on public.notas;
create policy notas_owner_all on public.notas
  for all
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy eventos_owner_all on public.eventos;
create policy eventos_owner_all on public.eventos
  for all
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy procedimientos_owner_all on public.procedimientos;
create policy procedimientos_owner_all on public.procedimientos
  for all
  using (exists (select 1 from public.clientes c
                 where c.id = procedimientos.cliente_id and c.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.clientes c
                      where c.id = procedimientos.cliente_id and c.owner_id = (select auth.uid())));

drop policy documentos_owner_all on public.documentos;
create policy documentos_owner_all on public.documentos
  for all
  using (exists (select 1 from public.clientes c
                 where c.id = documentos.cliente_id and c.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.clientes c
                      where c.id = documentos.cliente_id and c.owner_id = (select auth.uid())));

drop policy rentas_owner_all on public.rentas;
create policy rentas_owner_all on public.rentas
  for all
  using (exists (select 1 from public.clientes c
                 where c.id = rentas.cliente_id and c.owner_id = (select auth.uid())))
  with check (exists (select 1 from public.clientes c
                      where c.id = rentas.cliente_id and c.owner_id = (select auth.uid())));

drop policy ajustes_select_own on public.ajustes;
create policy ajustes_select_own on public.ajustes
  for select using (owner_id = (select auth.uid()));

drop policy ajustes_insert_own on public.ajustes;
create policy ajustes_insert_own on public.ajustes
  for insert with check (owner_id = (select auth.uid()));

drop policy ajustes_update_own on public.ajustes;
create policy ajustes_update_own on public.ajustes
  for update
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

drop policy ajustes_delete_own on public.ajustes;
create policy ajustes_delete_own on public.ajustes
  for delete using (owner_id = (select auth.uid()));

drop policy documentos_storage_owner_all on storage.objects;
create policy documentos_storage_owner_all on storage.objects
  for all
  using (bucket_id = 'documentos' and (storage.foldername(name))[1] = (select auth.uid())::text)
  with check (bucket_id = 'documentos' and (storage.foldername(name))[1] = (select auth.uid())::text);

-- Índices para las claves foráneas que no tenían.
create index documentos_procedimiento_id_idx on public.documentos(procedimiento_id);
create index eventos_owner_id_idx on public.eventos(owner_id);
create index notas_cliente_id_idx on public.notas(cliente_id);
