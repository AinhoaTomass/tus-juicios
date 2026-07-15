import 'package:flutter/material.dart';

import 'hairline_card.dart';

/// Tarjeta de estadística (número grande + etiqueta), usada en cuadrículas
/// 2x2 al principio de Inicio, Rentas y Facturas.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.valor, required this.etiqueta, this.onTap});

  final String valor;
  final String etiqueta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HairlineCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(valor, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Cuadrícula 2x2 de [StatTile].
class StatTileGrid extends StatelessWidget {
  const StatTileGrid({super.key, required this.tiles});

  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.9,
      children: tiles,
    );
  }
}
