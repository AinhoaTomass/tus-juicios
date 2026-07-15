// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formulario_sucio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Indica si el formulario abierto actualmente tiene cambios sin guardar.
/// Lo usan tanto el formulario (para el PopScope) como el AppShell (para
/// confirmar antes de cambiar de pestaña).

@ProviderFor(FormularioSucio)
final formularioSucioProvider = FormularioSucioProvider._();

/// Indica si el formulario abierto actualmente tiene cambios sin guardar.
/// Lo usan tanto el formulario (para el PopScope) como el AppShell (para
/// confirmar antes de cambiar de pestaña).
final class FormularioSucioProvider
    extends $NotifierProvider<FormularioSucio, bool> {
  /// Indica si el formulario abierto actualmente tiene cambios sin guardar.
  /// Lo usan tanto el formulario (para el PopScope) como el AppShell (para
  /// confirmar antes de cambiar de pestaña).
  FormularioSucioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'formularioSucioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$formularioSucioHash();

  @$internal
  @override
  FormularioSucio create() => FormularioSucio();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$formularioSucioHash() => r'4430d6e643432b03a35f38a40f7fdb30cc64ff50';

/// Indica si el formulario abierto actualmente tiene cambios sin guardar.
/// Lo usan tanto el formulario (para el PopScope) como el AppShell (para
/// confirmar antes de cambiar de pestaña).

abstract class _$FormularioSucio extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
