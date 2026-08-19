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

/// Cuadrícula de [StatTile], usada al principio de Inicio, Rentas y
/// Facturas. Cada tarjeta tiene un ancho máximo fijo y una altura que se
/// ajusta a su contenido (no a una relación de aspecto), así que en
/// pantallas anchas aparecen más columnas en vez de tarjetas enormes con
/// mucho hueco vacío.
class StatTileGrid extends StatelessWidget {
  const StatTileGrid({super.key, required this.tiles});

  final List<StatTile> tiles;

  static const _anchoMaximo = 220.0;
  static const _espacio = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var columnas =
            (constraints.maxWidth / (_anchoMaximo + _espacio)).floor().clamp(1, tiles.length);
        if (columnas < 2 && tiles.length >= 2) columnas = 2;
        final anchoTarjeta = (constraints.maxWidth - _espacio * (columnas - 1)) / columnas;
        return Wrap(
          spacing: _espacio,
          runSpacing: _espacio,
          children: tiles.map((tile) => SizedBox(width: anchoTarjeta, child: tile)).toList(),
        );
      },
    );
  }
}
