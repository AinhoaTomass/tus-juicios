# Base de datos (Supabase)

`migrations/` contiene, en orden, todos los cambios aplicados a la base de
datos del proyecto `tus-juicios`, con el mismo nombre y versión que tienen
en Supabase (`supabase_migrations.schema_migrations`). Ejecutadas de la
primera a la última reconstruyen el esquema completo: tablas, RLS,
triggers y el bucket `documentos` de Storage. No contienen datos.

Al hacer un cambio nuevo en la base de datos, guárdalo también aquí con el
nombre `<versión>_<nombre>.sql` que le asigne Supabase, para que el
repositorio y la base de datos no se desincronicen.

Reglas que deben cumplir todas las tablas nuevas: ver `CLAUDE.md` (RLS
desde la creación, filtrando por `auth.uid()`; nombres en español).
