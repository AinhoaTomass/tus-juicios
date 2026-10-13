create sequence if not exists public.facturas_numero_seq;

select setval(
  'public.facturas_numero_seq',
  coalesce((select max(numero::int) from public.facturas where numero ~ '^[0-9]+$'), 0)
);

alter table public.facturas
  alter column numero set default nextval('public.facturas_numero_seq')::text;
