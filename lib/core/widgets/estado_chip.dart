import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum EstadoTono { neutro, exito, aviso, urgente }

/// Chip de estado reutilizable (activo/pendiente/cerrado, vencido, urgente...).
/// Las features deciden qué [EstadoTono] corresponde a cada estado de dominio.
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.label, this.tono = EstadoTono.neutro});

  final String label;
  final EstadoTono tono;

  Color get _color => switch (tono) {
        EstadoTono.neutro => AppTheme.ink,
        EstadoTono.exito => const Color(0xFF3F7D4F),
        EstadoTono.aviso => AppTheme.accent,
        EstadoTono.urgente => const Color(0xFFB33A3A),
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );
    return Chip(
      label: Text(label, style: estilo),
      side: BorderSide(color: color, width: 1),
      backgroundColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
