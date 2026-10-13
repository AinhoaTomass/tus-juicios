-- Las facturas ya no se borran en cascada con el cliente:
-- si un cliente tiene facturas, la base de datos impide eliminarlo.
alter table public.facturas
  drop constraint facturas_cliente_id_fkey,
  add constraint facturas_cliente_id_fkey
    foreign key (cliente_id) references public.clientes(id) on delete restrict;
