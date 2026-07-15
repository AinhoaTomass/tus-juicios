// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'procedimientos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(procedimientoRepository)
final procedimientoRepositoryProvider = ProcedimientoRepositoryProvider._();

final class ProcedimientoRepositoryProvider
    extends
        $FunctionalProvider<
          ProcedimientoRepository,
          ProcedimientoRepository,
          ProcedimientoRepository
        >
    with $Provider<ProcedimientoRepository> {
  ProcedimientoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'procedimientoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$procedimientoRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProcedimientoRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProcedimientoRepository create(Ref ref) {
    return procedimientoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProcedimientoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProcedimientoRepository>(value),
    );
  }
}

String _$procedimientoRepositoryHash() =>
    r'2f5620ff0cccb9518f9515bb1f27f737c4b7e261';

@ProviderFor(ProcedimientosLista)
final procedimientosListaProvider = ProcedimientosListaProvider._();

final class ProcedimientosListaProvider
    extends $AsyncNotifierProvider<ProcedimientosLista, List<Procedimiento>> {
  ProcedimientosListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'procedimientosListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$procedimientosListaHash();

  @$internal
  @override
  ProcedimientosLista create() => ProcedimientosLista();
}

String _$procedimientosListaHash() =>
    r'fa64eb3014ecf5c4d41d36ca7980db4255d78f13';

abstract class _$ProcedimientosLista
    extends $AsyncNotifier<List<Procedimiento>> {
  FutureOr<List<Procedimiento>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Procedimiento>>, List<Procedimiento>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Procedimiento>>, List<Procedimiento>>,
              AsyncValue<List<Procedimiento>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ProcedimientosDeCliente)
final procedimientosDeClienteProvider = ProcedimientosDeClienteFamily._();

final class ProcedimientosDeClienteProvider
    extends
        $AsyncNotifierProvider<ProcedimientosDeCliente, List<Procedimiento>> {
  ProcedimientosDeClienteProvider._({
    required ProcedimientosDeClienteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'procedimientosDeClienteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$procedimientosDeClienteHash();

  @override
  String toString() {
    return r'procedimientosDeClienteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProcedimientosDeCliente create() => ProcedimientosDeCliente();

  @override
  bool operator ==(Object other) {
    return other is ProcedimientosDeClienteProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$procedimientosDeClienteHash() =>
    r'8e8ca5bc5eb2a74fd8adb6ef56f0b6df47823ca7';

final class ProcedimientosDeClienteFamily extends $Family
    with
        $ClassFamilyOverride<
          ProcedimientosDeCliente,
          AsyncValue<List<Procedimiento>>,
          List<Procedimiento>,
          FutureOr<List<Procedimiento>>,
          String
        > {
  ProcedimientosDeClienteFamily._()
    : super(
        retry: null,
        name: r'procedimientosDeClienteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProcedimientosDeClienteProvider call(String clienteId) =>
      ProcedimientosDeClienteProvider._(argument: clienteId, from: this);

  @override
  String toString() => r'procedimientosDeClienteProvider';
}

abstract class _$ProcedimientosDeCliente
    extends $AsyncNotifier<List<Procedimiento>> {
  late final _$args = ref.$arg as String;
  String get clienteId => _$args;

  FutureOr<List<Procedimiento>> build(String clienteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Procedimiento>>, List<Procedimiento>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Procedimiento>>, List<Procedimiento>>,
              AsyncValue<List<Procedimiento>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(procedimientoPorId)
final procedimientoPorIdProvider = ProcedimientoPorIdFamily._();

final class ProcedimientoPorIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<Procedimiento>,
          Procedimiento,
          FutureOr<Procedimiento>
        >
    with $FutureModifier<Procedimiento>, $FutureProvider<Procedimiento> {
  ProcedimientoPorIdProvider._({
    required ProcedimientoPorIdFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'procedimientoPorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$procedimientoPorIdHash();

  @override
  String toString() {
    return r'procedimientoPorIdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Procedimiento> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Procedimiento> create(Ref ref) {
    final argument = this.argument as (String, String);
    return procedimientoPorId(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ProcedimientoPorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$procedimientoPorIdHash() =>
    r'6446fd1813a2edfac514efddea8bff52cdb0a9a0';

final class ProcedimientoPorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Procedimiento>, (String, String)> {
  ProcedimientoPorIdFamily._()
    : super(
        retry: null,
        name: r'procedimientoPorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProcedimientoPorIdProvider call(String clienteId, String procedimientoId) =>
      ProcedimientoPorIdProvider._(
        argument: (clienteId, procedimientoId),
        from: this,
      );

  @override
  String toString() => r'procedimientoPorIdProvider';
}
