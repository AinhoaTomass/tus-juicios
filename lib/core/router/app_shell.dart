import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/eventos_providers.dart';
import '../../features/ajustes/presentation/ajustes_providers.dart';
import '../../features/clientes/presentation/procedimientos_providers.dart';
import '../network/supabase_client.dart';
import '../notificaciones/notificaciones_service.dart';
import '../state/formulario_sucio_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/confirmar_salida_dialog.dart';
import '../widgets/responsive_content.dart';

/// Shell con 5 secciones (Notas queda fuera para no saturar la barra
/// inferior; en el móvil se abre desde Inicio, en el panel lateral es una
/// entrada más, y está también en la ficha de
/// cada cliente). En móvil se muestra como barra
/// de navegación inferior; en pantallas anchas (tablet/escritorio) pasa a un
/// panel lateral (que se puede esconder) y el contenido se centra con un
/// ancho máximo. El layout master-detail de Clientes en tablet se resuelve
/// dentro de la propia feature (ver clientes/presentation).
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _destinos = [
    (icon: Icons.home_outlined, iconSeleccionado: Icons.home, label: 'Inicio'),
    (icon: Icons.people_outline, iconSeleccionado: Icons.people, label: 'Clientes'),
    (icon: Icons.event_outlined, iconSeleccionado: Icons.event, label: 'Agenda'),
    (icon: Icons.savings_outlined, iconSeleccionado: Icons.savings, label: 'Rentas'),
    (
      icon: Icons.receipt_long_outlined,
      iconSeleccionado: Icons.receipt_long,
      label: 'Facturas',
    ),
  ];

  bool _menuVisible = true;

  Future<void> _cambiarPestana(BuildContext context, int index) async {
    if (ref.read(formularioSucioProvider)) {
      final salir = await confirmarSalirSinGuardar(context);
      if (!salir) return;
      ref.read(formularioSucioProvider.notifier).limpiar();
    }
    // Siempre resetea la rama a su pantalla raíz: cada pestaña debe mostrar
    // su listado, no un formulario a medio rellenar que quedó abierto.
    if (context.mounted) widget.shell.goBranch(index, initialLocation: true);
  }

  /// Reprograma los recordatorios locales (citas y procedimientos por
  /// vencer) cada vez que cambian los datos de agenda o procedimientos.
  /// Solo tiene sentido en móvil: en web no se piden ni se programan.
  void _reprogramarRecordatorios() {
    if (kIsWeb) return;
    final eventos = ref.read(eventosListaProvider).value;
    final procedimientos = ref.read(procedimientosListaProvider).value;
    final config = ref.read(recordatoriosConfigProvider).value;
    if (eventos == null || procedimientos == null || config == null) return;
    NotificacionesService.instancia.reprogramar(
      eventos: eventos,
      procedimientos: procedimientos,
      config: config,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(eventosListaProvider, (_, _) => _reprogramarRecordatorios());
    ref.listen(procedimientosListaProvider, (_, _) => _reprogramarRecordatorios());
    ref.listen(recordatoriosConfigProvider, (_, _) => _reprogramarRecordatorios());

    final ancho = MediaQuery.sizeOf(context).width;
    final esPanelLateral = ancho >= anchoPanelLateral;
    final extendido = ancho >= 1000;

    final contenido = ResponsiveContent(child: widget.shell);

    if (!esPanelLateral) {
      return Scaffold(
        body: contenido,
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.shell.currentIndex,
          onDestinationSelected: (index) => _cambiarPestana(context, index),
          destinations: [
            for (final destino in _destinos)
              NavigationDestination(
                icon: Icon(destino.icon),
                selectedIcon: Icon(destino.iconSeleccionado),
                label: destino.label,
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          if (_menuVisible)
            NavigationRail(
              extended: extendido,
              selectedIndex: widget.shell.currentIndex,
              // Notas va después de las 5 secciones: no es una pestaña del
              // shell (en el móvil no cabe en la barra inferior), así que se
              // abre encima en vez de cambiar de rama.
              onDestinationSelected: (index) => index == _destinos.length
                  ? context.push('/notas')
                  : _cambiarPestana(context, index),
              labelType: extendido
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              trailingAtBottom: true,
              trailing: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment:
                        extendido ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      _AccionLateral(
                        icono: Icons.settings_outlined,
                        texto: 'Ajustes',
                        conTexto: extendido,
                        onPressed: () => context.push('/ajustes'),
                      ),
                      _AccionLateral(
                        icono: Icons.logout,
                        texto: 'Cerrar sesión',
                        conTexto: extendido,
                        onPressed: () => supabase.auth.signOut(),
                      ),
                      _AccionLateral(
                        icono: Icons.menu_open,
                        texto: 'Ocultar menú',
                        conTexto: extendido,
                        onPressed: () => setState(() => _menuVisible = false),
                      ),
                    ],
                  ),
                ),
              ),
              destinations: [
                for (final destino in _destinos)
                  NavigationRailDestination(
                    icon: Icon(destino.icon),
                    selectedIcon: Icon(destino.iconSeleccionado),
                    label: Text(destino.label),
                  ),
                const NavigationRailDestination(
                  icon: Icon(Icons.sticky_note_2_outlined),
                  selectedIcon: Icon(Icons.sticky_note_2),
                  label: Text('Notas'),
                ),
              ],
            )
          else
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  tooltip: 'Mostrar menú',
                  onPressed: () => setState(() => _menuVisible = true),
                ),
              ),
            ),
          if (_menuVisible) const VerticalDivider(width: 1),
          Expanded(child: contenido),
        ],
      ),
    );
  }
}

/// Acción secundaria al pie del panel lateral: con su nombre al lado cuando
/// el panel está extendido, o solo el icono (con tooltip) cuando es estrecho.
class _AccionLateral extends StatelessWidget {
  const _AccionLateral({
    required this.icono,
    required this.texto,
    required this.conTexto,
    required this.onPressed,
  });

  final IconData icono;
  final String texto;
  final bool conTexto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!conTexto) {
      return IconButton(icon: Icon(icono), tooltip: texto, onPressed: onPressed);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icono, size: 20),
        label: Text(texto),
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.of(context).mutedInk,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
