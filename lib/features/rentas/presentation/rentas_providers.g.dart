// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rentas_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rentaRepository)
final rentaRepositoryProvider = RentaRepositoryProvider._();

final class RentaRepositoryProvider
    extends
        $FunctionalProvider<RentaRepository, RentaRepository, RentaRepository>
    with $Provider<RentaRepository> {
  RentaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentaRepositoryHash();

  @$internal
  @override
  $ProviderElement<RentaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RentaRepository create(Ref ref) {
    return rentaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RentaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RentaRepository>(value),
    );
  }
}

String _$rentaRepositoryHash() => r'74b5d0a07a5acc6b7df9257fb2e806bd9be7ef88';

@ProviderFor(RentasLista)
final rentasListaProvider = RentasListaProvider._();

final class RentasListaProvider
    extends $AsyncNotifierProvider<RentasLista, List<Renta>> {
  RentasListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rentasListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rentasListaHash();

  @$internal
  @override
  RentasLista create() => RentasLista();
}

String _$rentasListaHash() => r'53aa272c810cd47c14388b36d097f3f6a65a723a';

abstract class _$RentasLista extends $AsyncNotifier<List<Renta>> {
  FutureOr<List<Renta>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Renta>>, List<Renta>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Renta>>, List<Renta>>,
              AsyncValue<List<Renta>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(rentaPorId)
final rentaPorIdProvider = RentaPorIdFamily._();

final class RentaPorIdProvider
    extends $FunctionalProvider<AsyncValue<Renta>, Renta, FutureOr<Renta>>
    with $FutureModifier<Renta>, $FutureProvider<Renta> {
  RentaPorIdProvider._({
    required RentaPorIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rentaPorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rentaPorIdHash();

  @override
  String toString() {
    return r'rentaPorIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Renta> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Renta> create(Ref ref) {
    final argument = this.argument as String;
    return rentaPorId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RentaPorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rentaPorIdHash() => r'90c82339338086f9d99fcf9c1517dff182a3c219';

final class RentaPorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Renta>, String> {
  RentaPorIdFamily._()
    : super(
        retry: null,
        name: r'rentaPorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RentaPorIdProvider call(String id) =>
      RentaPorIdProvider._(argument: id, from: this);

  @override
  String toString() => r'rentaPorIdProvider';
}
