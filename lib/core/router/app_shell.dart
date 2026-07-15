import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell con las 6 secciones del prototipo. En móvil se muestra como barra
/// de navegación inferior; el layout master-detail de Clientes en tablet
/// se resuelve dentro de la propia feature (ver clientes/presentation).
class AppShell extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(
          index,
          initialLocation: index == shell.currentIndex,
        ),
        destinations: _destinations,
      ),
    );
  }
}
