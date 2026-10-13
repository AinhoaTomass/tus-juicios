alter table public.eventos
  add column owner_id uuid references auth.users(id);

update public.eventos e
  set owner_id = c.owner_id
  from public.clientes c
  where c.id = e.cliente_id;

alter table public.eventos
  alter column owner_id set not null,
  alter column owner_id set default auth.uid();

alter table public.eventos
  alter column cliente_id drop not null;

alter table public.eventos
  drop constraint eventos_tipo_check;

alter table public.eventos
  add constraint eventos_tipo_check
    check (tipo = any (array['Juicio'::text, 'SMAC'::text, 'Conciliacion'::text, 'Otro'::text]));

drop policy eventos_owner_all on public.eventos;

create policy eventos_owner_all on public.eventos
  for all
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());
