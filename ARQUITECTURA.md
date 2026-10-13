# Arquitectura de TusJuicios

App de gestión para un despacho (clientes, procedimientos, agenda, rentas,
facturas y notas). Una sola base de código Flutter para Android, iOS y web,
con Supabase como backend (base de datos Postgres, autenticación y
almacenamiento de documentos).

## 1. Piezas

| Pieza | Qué es |
|---|---|
| App | Flutter. Riverpod (con generador) para el estado, go_router para la navegación. |
| Backend | Supabase, proyecto `tus-juicios` (región eu-west-3, París). |
| Web | GitHub Pages en `https://ainhoatomass.github.io/tus-juicios/`; se publica sola con cada push a `master` (`.github/workflows/deploy-web.yml`). |
| Móvil | Lo compila e instala el usuario desde su equipo. |
| Credenciales | URL y clave publicable de Supabase vía `--dart-define` (en la web, desde los secrets de GitHub). Nunca en el código. |

## 2. Estructura de carpetas

```
lib/
  core/          Piezas comunes a todas las secciones
    auth/        Cierre de sesión por inactividad
    formato/     Importes (1.234,50 €), fechas para Supabase, comparaciones por día
    network/     Cliente de Supabase
    notificaciones/  Recordatorios locales (solo móvil)
    router/      Rutas, barra inferior / panel lateral
    state/       Estado compartido (formulario con cambios sin guardar)
    theme/       Tema "Classical": colores (AppColors) y tipografía
    widgets/     Componentes reutilizables (tarjetas, chips, mostrarError...)
  features/<sección>/
    domain/       Entidades y reglas de negocio puras (sin Flutter ni Supabase)
    data/         Repositorios de Supabase y mappers fila ↔ entidad
    presentation/ Pantallas y providers de Riverpod
supabase/migrations/  Historial completo de cambios de la base de datos
test/                 Tests unitarios (sin conexión)
```

Secciones (`features/`): `auth`, `inicio`, `clientes` (incluye
procedimientos, documentos y papelera), `agenda`, `rentas`, `facturas`,
`notas`, `ajustes`. Los nombres de dominio van en español (ver `CLAUDE.md`).

## 3. Flujo de datos

1. La pantalla lee un provider (`ref.watch(clientesListaProvider)`).
2. El provider pide los datos a su repositorio (`ClienteRepository`), que
   es una interfaz en `domain/` con su implementación de Supabase en `data/`.
3. El mapper convierte cada fila en una entidad (`toCliente()`) y al revés
   (`toRow()`).
4. Tras guardar, la pantalla invalida los providers afectados para que se
   recarguen.

Los cálculos (totales de facturas, urgencias, vencimientos) viven en
`domain/` como funciones puras, para que todas las pantallas den las mismas
cifras y se puedan probar sin conexión. Los errores al guardar o borrar se
muestran siempre con `mostrarError()` (`core/widgets/mostrar_error.dart`).

## 4. Base de datos y seguridad

Toda tabla tiene **Row Level Security (RLS)** activada, filtrando por el
usuario autenticado:

- Tablas con dueño propio (`clientes`, `notas`, `eventos`, `ajustes`,
  `series_facturas`): columna `owner_id uuid default auth.uid()` y política
  `owner_id = (select auth.uid())`.
- Tablas que cuelgan de un cliente (`procedimientos`, `documentos`,
  `rentas`, `facturas`): la política comprueba que el cliente pertenece al
  usuario (`exists (select 1 from clientes c where c.id = ... and c.owner_id = (select auth.uid()))`).
- Documentos (Storage, bucket privado `documentos`): cada archivo se guarda
  en `<uid>/<cliente>/...` y la política solo permite acceder a la carpeta
  propia. Se descargan con URLs firmadas de 5 minutos.

`auth.uid()` va siempre envuelto en `(select ...)` para que Postgres lo
calcule una vez por consulta y no fila a fila.

Hay más de una cuenta en el proyecto; cada una solo ve sus datos.

## 5. Facturas

- **Numeración** por usuario y año: `2026/001`, `2026/002`... La asigna un
  trigger al insertar, con un contador en `series_facturas` que avanza en
  la misma transacción, así que un alta fallida no deja huecos. Al editar,
  otro trigger impide cambiar número, año o serie. Las facturas anteriores
  al cambio conservan su número antiguo (`1`, `2`, `3`).
- **No se pueden borrar**: no hay política RLS de borrado y un trigger
  rechaza cualquier `DELETE`, incluso desde el panel de Supabase. Una
  factura errónea se corrige con una rectificativa.
- **Un cliente con facturas no se puede eliminar** (`on delete restrict`);
  la papelera lo explica al usuario.

## 6. Fechas e importes

- Columnas `date` (citas, facturas, vencimientos, rentas): se envían como
  `2026-10-13` (`fechaParaBd`) y se leen como medianoche local.
- Columnas `timestamptz` (notas, subida de documentos, papelera): se envían
  en UTC (`instanteParaBd`) y se leen en hora local (`leerInstante`).
- Lo de "hoy" se compara por día de calendario (`core/formato/dias.dart`),
  nunca contra `DateTime.now()` directamente.
- Importes siempre con `formatearImporte()` (formato español).

## 7. Reglas para cambios en la base de datos

- Toda tabla nueva lleva RLS activado **en la misma migración que la
  crea**, filtrando por `auth.uid()` como en la sección 4, aunque hoy solo
  la use un usuario. No se crean tablas "para activar RLS después".
- Cada cambio se aplica como migración y se guarda también en
  `supabase/migrations/<versión>_<nombre>.sql` (ver `supabase/README.md`).
- Los cambios en producción se revisan antes de aplicarlos; los de datos
  se prueban primero dentro de una transacción que se deshace.
- Antes de quitar una columna que la app envía, hay que esperar a que
  todas las instalaciones (móvil y web) tengan la versión que ya no la usa:
  si no, la app vieja falla al guardar.

## 8. Tests

`flutter test` ejecuta tests unitarios de la lógica pura (formato, fechas,
reglas de dominio, mappers). No arrancan la app ni necesitan Supabase.

## 9. Pendiente

- Quitar la columna `clientes.fecha_vencimiento` (y su índice) de la base de
  datos. Ya no la usa la app (ningún cliente tenía fecha), pero las
  versiones antiguas del móvil todavía la envían al guardar: quitarla
  cuando todos los móviles estén actualizados.
- Copias de seguridad: ahora no hay ninguna fuera de Supabase.
