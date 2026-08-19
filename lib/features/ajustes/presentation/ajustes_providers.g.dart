// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ajustes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TemaModoNotifier)
final temaModoProvider = TemaModoNotifierProvider._();

final class TemaModoNotifierProvider
    extends $AsyncNotifierProvider<TemaModoNotifier, ThemeMode> {
  TemaModoNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'temaModoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$temaModoNotifierHash();

  @$internal
  @override
  TemaModoNotifier create() => TemaModoNotifier();
}

String _$temaModoNotifierHash() => r'e07ef2fecf47ac3f7b00da41e7ac6ecd21baf1c4';

abstract class _$TemaModoNotifier extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
    r'a81d42628e170a76ac910de06b48c4c3220d8a7b';

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
    r'1334ba88df97d043b9a4855f47a69855dddfa9f1';

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
