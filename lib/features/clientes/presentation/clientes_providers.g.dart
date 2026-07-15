// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clientes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clienteRepository)
final clienteRepositoryProvider = ClienteRepositoryProvider._();

final class ClienteRepositoryProvider
    extends
        $FunctionalProvider<
          ClienteRepository,
          ClienteRepository,
          ClienteRepository
        >
    with $Provider<ClienteRepository> {
  ClienteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clienteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clienteRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClienteRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClienteRepository create(Ref ref) {
    return clienteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClienteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClienteRepository>(value),
    );
  }
}

String _$clienteRepositoryHash() => r'7b2041f76b381fbceb69daef864e3a283173e9f7';

@ProviderFor(ClientesLista)
final clientesListaProvider = ClientesListaProvider._();

final class ClientesListaProvider
    extends $AsyncNotifierProvider<ClientesLista, List<Cliente>> {
  ClientesListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientesListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientesListaHash();

  @$internal
  @override
  ClientesLista create() => ClientesLista();
}

String _$clientesListaHash() => r'78414f791cfc06a5df84a777587e2aff9ef43509';

abstract class _$ClientesLista extends $AsyncNotifier<List<Cliente>> {
  FutureOr<List<Cliente>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Cliente>>, List<Cliente>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Cliente>>, List<Cliente>>,
              AsyncValue<List<Cliente>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(clientePorId)
final clientePorIdProvider = ClientePorIdFamily._();

final class ClientePorIdProvider
    extends $FunctionalProvider<AsyncValue<Cliente>, Cliente, FutureOr<Cliente>>
    with $FutureModifier<Cliente>, $FutureProvider<Cliente> {
  ClientePorIdProvider._({
    required ClientePorIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientePorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientePorIdHash();

  @override
  String toString() {
    return r'clientePorIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Cliente> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Cliente> create(Ref ref) {
    final argument = this.argument as String;
    return clientePorId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClientePorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientePorIdHash() => r'3b43be300554315cdd544c9a807421fa119b260a';

final class ClientePorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Cliente>, String> {
  ClientePorIdFamily._()
    : super(
        retry: null,
        name: r'clientePorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientePorIdProvider call(String id) =>
      ClientePorIdProvider._(argument: id, from: this);

  @override
  String toString() => r'clientePorIdProvider';
}
