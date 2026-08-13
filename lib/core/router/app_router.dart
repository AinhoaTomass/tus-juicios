import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/agenda/presentation/agenda_screen.dart';
import '../../features/agenda/presentation/evento_formulario_screen.dart';
import '../../features/ajustes/presentation/ajustes_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/clientes/presentation/cliente_ficha_screen.dart';
import '../../features/clientes/presentation/cliente_formulario_screen.dart';
import '../../features/clientes/presentation/clientes_lista_screen.dart';
import '../../features/clientes/presentation/papelera_screen.dart';
import '../../features/clientes/presentation/procedimiento_formulario_screen.dart';
import '../../features/clientes/presentation/procedimientos_lista_screen.dart';
import '../../features/facturas/presentation/factura_formulario_screen.dart';
import '../../features/facturas/presentation/facturas_screen.dart';
import '../../features/inicio/presentation/inicio_screen.dart';
import '../../features/notas/presentation/nota_formulario_screen.dart';
import '../../features/notas/presentation/notas_screen.dart';
import '../../features/rentas/presentation/renta_formulario_screen.dart';
import '../../features/rentas/presentation/rentas_screen.dart';
import '../network/supabase_client.dart';
import 'app_shell.dart';
import 'go_router_refresh_stream.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final refreshStream = GoRouterRefreshStream(supabase.auth.onAuthStateChange);
  ref.onDispose(refreshStream.dispose);

  return GoRouter(
    initialLocation: '/inicio',
    refreshListenable: Listenable.merge([refreshStream, isPasswordRecovery]),
    redirect: (context, state) {
      final haySesion = supabase.auth.currentSession != null;
      final enLogin = state.matchedLocation == '/login';
      final enResetPassword = state.matchedLocation == '/reset-password';

      if (isPasswordRecovery.value) {
        return enResetPassword ? null : '/reset-password';
      }
      if (!haySesion && !enLogin) return '/login';
      if (haySesion && enLogin) return '/inicio';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/reset-password', builder: (context, state) => const ResetPasswordScreen()),
      GoRoute(path: '/ajustes', builder: (context, state) => const AjustesScreen()),
      GoRoute(
        path: '/procedimientos',
        builder: (context, state) => const ProcedimientosListaScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/inicio', builder: (context, state) => const InicioScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clientes',
                builder: (context, state) => const ClientesListaScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const ClienteFormularioScreen(),
                  ),
                  GoRoute(
                    path: 'papelera',
                    builder: (context, state) => const PapeleraScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        ClienteFichaScreen(clienteId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (context, state) => ClienteFormularioScreen(
                          clienteId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'procedimientos/nuevo',
                        builder: (context, state) => ProcedimientoFormularioScreen(
                          clienteId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: 'procedimientos/:procedimientoId/editar',
                        builder: (context, state) => ProcedimientoFormularioScreen(
                          clienteId: state.pathParameters['id']!,
                          procedimientoId: state.pathParameters['procedimientoId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/agenda',
                builder: (context, state) => const AgendaScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const EventoFormularioScreen(),
                  ),
                  GoRoute(
                    path: ':eventoId/editar',
                    builder: (context, state) => EventoFormularioScreen(
                      eventoId: state.pathParameters['eventoId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/rentas',
                builder: (context, state) => const RentasScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const RentaFormularioScreen(),
                  ),
                  GoRoute(
                    path: ':rentaId/editar',
                    builder: (context, state) => RentaFormularioScreen(
                      rentaId: state.pathParameters['rentaId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/facturas',
                builder: (context, state) => const FacturasScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const FacturaFormularioScreen(),
                  ),
                  GoRoute(
                    path: ':facturaId/editar',
                    builder: (context, state) => FacturaFormularioScreen(
                      facturaId: state.pathParameters['facturaId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notas',
                builder: (context, state) => const NotasScreen(),
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const NotaFormularioScreen(),
                  ),
                  GoRoute(
                    path: ':notaId/editar',
                    builder: (context, state) => NotaFormularioScreen(
                      notaId: state.pathParameters['notaId'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
