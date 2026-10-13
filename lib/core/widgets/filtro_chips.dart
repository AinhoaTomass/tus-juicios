import 'package:flutter/material.dart';

/// Chips de filtro de selección única. Pasan a la línea siguiente cuando no
/// caben: con un desplazamiento horizontal, en el ordenador el último chip
/// quedaba cortado y no se podía arrastrar con el ratón.
class FiltroChips<T> extends StatelessWidget {
  const FiltroChips({super.key, required this.opciones, required this.seleccion, required this.onChanged});

  final List<(T valor, String etiqueta)> opciones;
  final T seleccion;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcion in opciones)
          ChoiceChip(
            label: Text(opcion.$2),
            selected: seleccion == opcion.$1,
            onSelected: (_) => onChanged(opcion.$1),
          ),
      ],
    );
  }
}
