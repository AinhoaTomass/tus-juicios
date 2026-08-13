// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajustes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecordatoriosConfigNotifier)
final recordatoriosConfigProvider = RecordatoriosConfigNotifierProvider._();

final class RecordatoriosConfigNotifierProvider
    extends
        $AsyncNotifierProvider<
          RecordatoriosConfigNotifier,
          RecordatoriosConfig
        > {
  RecordatoriosConfigNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recordatoriosConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recordatoriosConfigNotifierHash();

  @$internal
  @override
  RecordatoriosConfigNotifier create() => RecordatoriosConfigNotifier();
}

String _$recordatoriosConfigNotifierHash() =>
    r'93cadb9c7a1e8a690f82563d9baae23048fec283';

abstract class _$RecordatoriosConfigNotifier
    extends $AsyncNotifier<RecordatoriosConfig> {
  FutureOr<RecordatoriosConfig> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<RecordatoriosConfig>, RecordatoriosConfig>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecordatoriosConfig>, RecordatoriosConfig>,
              AsyncValue<RecordatoriosConfig>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DatosDespachoNotifier)
final datosDespachoProvider = DatosDespachoNotifierProvider._();

final class DatosDespachoNotifierProvider
    extends $AsyncNotifierProvider<DatosDespachoNotifier, DatosDespacho> {
  DatosDespachoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'datosDespachoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$datosDespachoNotifierHash();

  @$internal
  @override
  DatosDespachoNotifier create() => DatosDespachoNotifier();
}

String _$datosDespachoNotifierHash() =>
    r'8cf67ad3bc1226706b330a79467f58d657dafc07';

abstract class _$DatosDespachoNotifier extends $AsyncNotifier<DatosDespacho> {
  FutureOr<DatosDespacho> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DatosDespacho>, DatosDespacho>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DatosDespacho>, DatosDespacho>,
              AsyncValue<DatosDespacho>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
