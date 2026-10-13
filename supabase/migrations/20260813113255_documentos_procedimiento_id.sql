alter table documentos
  add column procedimiento_id uuid references procedimientos(id) on delete set null;
