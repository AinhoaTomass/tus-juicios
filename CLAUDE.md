# Reglas del proyecto — TusJuicios

## No ejecutar la app

Nunca lances ni sirvas la aplicación en ejecución: nada de `flutter run`, `flutter run -d web-server/chrome/edge/windows`, emuladores, ni cualquier dev server de la app. El usuario la ejecuta siempre él mismo (normalmente en su móvil).

Sí está permitido usar comandos de verificación estática que no arrancan el runtime de la app: `flutter analyze`, `flutter test`, `flutter pub get`, `dart run build_runner build`, `flutter create` (scaffolding). Ante la duda de si un comando "ejecuta" la app, no lo ejecutes y pregunta primero.

## No acceder a secretos de otras apps

No leas, muestres ni copies claves, tokens o credenciales de otras aplicaciones o proyectos en esta máquina (`.env`, `google-services.json`, `local.properties`, keystores, credenciales de Supabase/Firebase/APIs de otros repos, etc.).

Las credenciales de este proyecto (Supabase URL / publishable key) se inyectan siempre vía `--dart-define`, aportadas por el usuario en su propia ejecución — nunca las necesitas para trabajar en este repo, así que no hay que leerlas ni pedirlas.

## RLS obligatorio en Supabase

Cualquier tabla nueva en Supabase (clientes, procedimientos, documentos, eventos, rentas, facturas, notas, y las que vengan) lleva Row Level Security activado desde el momento en que se crea, filtrando por `auth.uid()`, aunque hoy solo haya un usuario. No se crean tablas "para activar RLS después" — ver sección 4 y 7 de `ARQUITECTURA.md`.

## Nombres de dominio en español

Entidades, features, campos y nombres de tablas van en español, siguiendo el lenguaje del despacho: `Cliente`, `Procedimiento`, `Renta`, `Factura`, `Nota`, `Evento`, no sus traducciones al inglés. Ya está así en `features/clientes`; mantenerlo al construir Agenda, Rentas, Facturas y Notas.
