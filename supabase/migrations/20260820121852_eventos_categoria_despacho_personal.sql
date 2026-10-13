alter table public.eventos
  add column categoria text;

update public.eventos
  set categoria = case when cliente_id is not null then 'Despacho' else 'Personal' end;

alter table public.eventos
  alter column categoria set not null,
  add constraint eventos_categoria_check
    check (categoria = any (array['Despacho'::text, 'Personal'::text]));
