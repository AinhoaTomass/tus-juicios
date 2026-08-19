import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Caja pequeña con borde dorado mostrando un contador (p.ej. junto a un
/// título de sección: "Próximos eventos [5]").
class ContadorBadge extends StatelessWidget {
  const ContadorBadge({super.key, required this.valor});

  final int valor;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.of(context).accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: accent),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$valor',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: accent),
      ),
    );
  }
}
