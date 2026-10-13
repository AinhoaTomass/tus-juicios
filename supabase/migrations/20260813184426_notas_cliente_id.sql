alter table notas
  add column cliente_id uuid references clientes(id) on delete set null;
