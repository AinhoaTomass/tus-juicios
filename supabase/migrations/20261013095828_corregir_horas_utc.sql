-- Hora local guardada como UTC antes del 13/10/2026: se reinterpreta como
-- hora de Madrid para obtener el instante correcto. Solo filas existentes
-- al corte (2026-10-13 09:56:10 UTC); lo creado después ya es correcto.
update public.notas
set fecha = (fecha at time zone 'UTC') at time zone 'Europe/Madrid'
where created_at <= '2026-10-13 09:56:10+00';

update public.documentos
set fecha_subida = (fecha_subida at time zone 'UTC') at time zone 'Europe/Madrid'
where fecha_subida::time = '00:00'
   or id in ('9940a1e7-ed51-4098-bb10-4c623612903b',
             '6b5dd799-d4ff-4339-809e-f109ee64474c',
             'b0bf473f-bfa3-4ed1-86d7-fe07ec7f0fab');
