import 'package:flutter/material.dart';

/// Muestra un diálogo de confirmación y devuelve true si el usuario
/// confirma que quiere salir sin guardar los cambios.
Future<bool> confirmarSalirSinGuardar(BuildContext context) async {
  final salir = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¿Salir sin guardar?'),
      content: const Text('Vas a perder los cambios que has hecho en este formulario.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Salir sin guardar'),
        ),
      ],
    ),
  );
  return salir ?? false;
}
