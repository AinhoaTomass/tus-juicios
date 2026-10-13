import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum EstadoTono { neutro, exito, aviso, urgente }

/// Chip de estado reutilizable (activo/pendiente/cerrado, vencido, urgente...).
/// Las features deciden qué [EstadoTono] corresponde a cada estado de dominio.
class EstadoChip extends StatelessWidget {
  const EstadoChip({super.key, required this.label, this.tono = EstadoTono.neutro});

  final String label;
  final EstadoTono tono;

  Color _color(BuildContext context) => switch (tono) {
        EstadoTono.neutro => AppTheme.of(context).ink,
        EstadoTono.exito => AppTheme.of(context).exito,
        EstadoTono.aviso => AppTheme.of(context).accentInk,
        EstadoTono.urgente => AppTheme.of(context).urgente,
      };

  String get _labelCapitalizado =>
      label.isEmpty ? label : label[0].toUpperCase() + label.substring(1);

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    final estilo = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        );
    return Chip(
      label: Text(_labelCapitalizado, style: estilo),
      side: BorderSide(color: color, width: 1),
      backgroundColor: Colors.transparent,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
