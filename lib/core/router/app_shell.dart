import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/eventos_providers.dart';
import '../../features/ajustes/presentation/ajustes_providers.dart';
import '../../features/clientes/presentation/procedimientos_providers.dart';
import '../notificaciones/notificaciones_service.dart';
import '../state/formulario_sucio_provider.dart';
import '../widgets/confirmar_salida_dialog.dart';
import '../widgets/responsive_content.dart';

/// Shell con las 6 secciones del prototipo. En móvil se muestra como barra
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
  static const _anchoPanelLateral = 700.0;

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
    (
      icon: Icons.sticky_note_2_outlined,
      iconSeleccionado: Icons.sticky_note_2,
      label: 'Notas',
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
    final esPanelLateral = ancho >= _anchoPanelLateral;

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
              extended: ancho >= 1000,
              selectedIndex: widget.shell.currentIndex,
              onDestinationSelected: (index) => _cambiarPestana(context, index),
              labelType: ancho >= 1000
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              leading: IconButton(
                icon: const Icon(Icons.menu_open),
                tooltip: 'Ocultar menú',
                onPressed: () => setState(() => _menuVisible = false),
              ),
              destinations: [
                for (final destino in _destinos)
                  NavigationRailDestination(
                    icon: Icon(destino.icon),
                    selectedIcon: Icon(destino.iconSeleccionado),
                    label: Text(destino.label),
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
