import 'package:flutter/material.dart';

/// Barra horizontal de chips de filtro de selección única.
class FiltroChips<T> extends StatelessWidget {
  const FiltroChips({super.key, required this.opciones, required this.seleccion, required this.onChanged});

  final List<(T valor, String etiqueta)> opciones;
  final T seleccion;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final opcion in opciones)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(opcion.$2),
                selected: seleccion == opcion.$1,
                onSelected: (_) => onChanged(opcion.$1),
              ),
            ),
        ],
      ),
    );
  }
}
