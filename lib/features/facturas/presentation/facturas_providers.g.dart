// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'facturas_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(facturaRepository)
final facturaRepositoryProvider = FacturaRepositoryProvider._();

final class FacturaRepositoryProvider
    extends
        $FunctionalProvider<
          FacturaRepository,
          FacturaRepository,
          FacturaRepository
        >
    with $Provider<FacturaRepository> {
  FacturaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facturaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facturaRepositoryHash();

  @$internal
  @override
  $ProviderElement<FacturaRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FacturaRepository create(Ref ref) {
    return facturaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacturaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacturaRepository>(value),
    );
  }
}

String _$facturaRepositoryHash() => r'65c7dd7cae119faf24b58a7ab1c6d51c67b1b31d';

@ProviderFor(FacturasLista)
final facturasListaProvider = FacturasListaProvider._();

final class FacturasListaProvider
    extends $AsyncNotifierProvider<FacturasLista, List<Factura>> {
  FacturasListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facturasListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facturasListaHash();

  @$internal
  @override
  FacturasLista create() => FacturasLista();
}

String _$facturasListaHash() => r'3011db6b9ebbab48461f7f0d76e16ed59be7be75';

abstract class _$FacturasLista extends $AsyncNotifier<List<Factura>> {
  FutureOr<List<Factura>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Factura>>, List<Factura>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Factura>>, List<Factura>>,
              AsyncValue<List<Factura>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(facturaPorId)
final facturaPorIdProvider = FacturaPorIdFamily._();

final class FacturaPorIdProvider
    extends $FunctionalProvider<AsyncValue<Factura>, Factura, FutureOr<Factura>>
    with $FutureModifier<Factura>, $FutureProvider<Factura> {
  FacturaPorIdProvider._({
    required FacturaPorIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'facturaPorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$facturaPorIdHash();

  @override
  String toString() {
    return r'facturaPorIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Factura> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Factura> create(Ref ref) {
    final argument = this.argument as String;
    return facturaPorId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FacturaPorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$facturaPorIdHash() => r'1266329b633bc009080d7222a78100d5459b29f3';

final class FacturaPorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Factura>, String> {
  FacturaPorIdFamily._()
    : super(
        retry: null,
        name: r'facturaPorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FacturaPorIdProvider call(String id) =>
      FacturaPorIdProvider._(argument: id, from: this);

  @override
  String toString() => r'facturaPorIdProvider';
}
