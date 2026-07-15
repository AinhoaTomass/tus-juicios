import 'package:flutter/material.dart';

import '../../../core/network/supabase_client.dart';
import '../../../core/widgets/hairline_card.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Resumen', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const HairlineCard(child: Text('Próximos eventos y notificaciones de vencimiento aparecerán aquí.')),
        ],
      ),
    );
  }
}
