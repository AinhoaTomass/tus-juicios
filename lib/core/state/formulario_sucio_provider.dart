import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'formulario_sucio_provider.g.dart';

/// Indica si el formulario abierto actualmente tiene cambios sin guardar.
/// Lo usan tanto el formulario (para el PopScope) como el AppShell (para
/// confirmar antes de cambiar de pestaña).
@riverpod
class FormularioSucio extends _$FormularioSucio {
  @override
  bool build() => false;

  void marcar() => state = true;

  void limpiar() => state = false;
}
