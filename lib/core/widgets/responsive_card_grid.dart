import 'package:flutter/material.dart';

/// Reparte tarjetas de listado en 1-3 columnas según el ancho disponible,
/// en vez de estirarlas de borde a borde en pantallas anchas (tablet/web).
/// No es scrollable por sí mismo: se coloca dentro de un `ListView` o
/// `SingleChildScrollView` ya existente.
class ResponsiveCardGrid<T> extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 12,
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = switch (constraints.maxWidth) {
          > 1100 => 3,
          > 650 => 2,
          _ => 1,
        };
        final anchoTarjeta = (constraints.maxWidth - spacing * (columnas - 1)) / columnas;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items
              .map((item) => SizedBox(width: anchoTarjeta, child: itemBuilder(context, item)))
              .toList(),
        );
      },
    );
  }
}
