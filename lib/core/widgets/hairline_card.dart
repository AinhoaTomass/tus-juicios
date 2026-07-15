import 'package:flutter/material.dart';

/// Tarjeta con borde fino y sin relleno de color, para listas de clientes,
/// fichas y paneles del dashboard.
class HairlineCard extends StatelessWidget {
  const HairlineCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: card,
    );
  }
}
