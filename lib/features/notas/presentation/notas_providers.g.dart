// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notas_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notaRepository)
final notaRepositoryProvider = NotaRepositoryProvider._();

final class NotaRepositoryProvider
    extends $FunctionalProvider<NotaRepository, NotaRepository, NotaRepository>
    with $Provider<NotaRepository> {
  NotaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notaRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotaRepository create(Ref ref) {
    return notaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotaRepository>(value),
    );
  }
}

String _$notaRepositoryHash() => r'4d195e10c8f456ddaacf2c45b76e5d2fa043fee4';

@ProviderFor(NotasLista)
final notasListaProvider = NotasListaProvider._();

final class NotasListaProvider
    extends $AsyncNotifierProvider<NotasLista, List<Nota>> {
  NotasListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notasListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notasListaHash();

  @$internal
  @override
  NotasLista create() => NotasLista();
}

String _$notasListaHash() => r'74899e2197db802d97d4b7f459d544e1fe298dda';

abstract class _$NotasLista extends $AsyncNotifier<List<Nota>> {
  FutureOr<List<Nota>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Nota>>, List<Nota>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Nota>>, List<Nota>>,
              AsyncValue<List<Nota>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(notaPorId)
final notaPorIdProvider = NotaPorIdFamily._();

final class NotaPorIdProvider
    extends $FunctionalProvider<AsyncValue<Nota>, Nota, FutureOr<Nota>>
    with $FutureModifier<Nota>, $FutureProvider<Nota> {
  NotaPorIdProvider._({
    required NotaPorIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'notaPorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notaPorIdHash();

  @override
  String toString() {
    return r'notaPorIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Nota> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Nota> create(Ref ref) {
    final argument = this.argument as String;
    return notaPorId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is NotaPorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notaPorIdHash() => r'1180b6235f22ae300dda34c01aeee8017140d282';

final class NotaPorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Nota>, String> {
  NotaPorIdFamily._()
    : super(
        retry: null,
        name: r'notaPorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotaPorIdProvider call(String id) =>
      NotaPorIdProvider._(argument: id, from: this);

  @override
  String toString() => r'notaPorIdProvider';
}
