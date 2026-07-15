import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/formulario_sucio_provider.dart';
import '../widgets/confirmar_salida_dialog.dart';

/// Shell con las 6 secciones del prototipo. En móvil se muestra como barra
/// de navegación inferior; el layout master-detail de Clientes en tablet
/// se resuelve dentro de la propia feature (ver clientes/presentation).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Clientes'),
    NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: 'Agenda'),
    NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Rentas'),
    NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Facturas'),
    NavigationDestination(icon: Icon(Icons.sticky_note_2_outlined), selectedIcon: Icon(Icons.sticky_note_2), label: 'Notas'),
  ];

  Future<void> _cambiarPestana(BuildContext context, WidgetRef ref, int index) async {
    if (ref.read(formularioSucioProvider)) {
      final salir = await confirmarSalirSinGuardar(context);
      if (!salir) return;
      ref.read(formularioSucioProvider.notifier).limpiar();
    }
    // Siempre resetea la rama a su pantalla raíz: cada pestaña debe mostrar
    // su listado, no un formulario a medio rellenar que quedó abierto.
    if (context.mounted) shell.goBranch(index, initialLocation: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => _cambiarPestana(context, ref, index),
        destinations: _destinations,
      ),
    );
  }
}
