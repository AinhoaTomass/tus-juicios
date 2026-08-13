// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documentos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(documentoRepository)
final documentoRepositoryProvider = DocumentoRepositoryProvider._();

final class DocumentoRepositoryProvider
    extends
        $FunctionalProvider<
          DocumentoRepository,
          DocumentoRepository,
          DocumentoRepository
        >
    with $Provider<DocumentoRepository> {
  DocumentoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'documentoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$documentoRepositoryHash();

  @$internal
  @override
  $ProviderElement<DocumentoRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DocumentoRepository create(Ref ref) {
    return documentoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DocumentoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DocumentoRepository>(value),
    );
  }
}

String _$documentoRepositoryHash() =>
    r'52b1227938b4cdf168e45ba1396321d932d5969b';

@ProviderFor(DocumentosDeCliente)
final documentosDeClienteProvider = DocumentosDeClienteFamily._();

final class DocumentosDeClienteProvider
    extends $AsyncNotifierProvider<DocumentosDeCliente, List<Documento>> {
  DocumentosDeClienteProvider._({
    required DocumentosDeClienteFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'documentosDeClienteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$documentosDeClienteHash();

  @override
  String toString() {
    return r'documentosDeClienteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DocumentosDeCliente create() => DocumentosDeCliente();

  @override
  bool operator ==(Object other) {
    return other is DocumentosDeClienteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$documentosDeClienteHash() =>
    r'75e6a097bb00ffb655a302143994d18ed996ab4b';

final class DocumentosDeClienteFamily extends $Family
    with
        $ClassFamilyOverride<
          DocumentosDeCliente,
          AsyncValue<List<Documento>>,
          List<Documento>,
          FutureOr<List<Documento>>,
          String
        > {
  DocumentosDeClienteFamily._()
    : super(
        retry: null,
        name: r'documentosDeClienteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DocumentosDeClienteProvider call(String clienteId) =>
      DocumentosDeClienteProvider._(argument: clienteId, from: this);

  @override
  String toString() => r'documentosDeClienteProvider';
}

abstract class _$DocumentosDeCliente extends $AsyncNotifier<List<Documento>> {
  late final _$args = ref.$arg as String;
  String get clienteId => _$args;

  FutureOr<List<Documento>> build(String clienteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Documento>>, List<Documento>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Documento>>, List<Documento>>,
              AsyncValue<List<Documento>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(DocumentosDeProcedimiento)
final documentosDeProcedimientoProvider = DocumentosDeProcedimientoFamily._();

final class DocumentosDeProcedimientoProvider
    extends $AsyncNotifierProvider<DocumentosDeProcedimiento, List<Documento>> {
  DocumentosDeProcedimientoProvider._({
    required DocumentosDeProcedimientoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'documentosDeProcedimientoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$documentosDeProcedimientoHash();

  @override
  String toString() {
    return r'documentosDeProcedimientoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DocumentosDeProcedimiento create() => DocumentosDeProcedimiento();

  @override
  bool operator ==(Object other) {
    return other is DocumentosDeProcedimientoProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$documentosDeProcedimientoHash() =>
    r'4e4464b88244024518e8b8a06dc9aeb5d031d040';

final class DocumentosDeProcedimientoFamily extends $Family
    with
        $ClassFamilyOverride<
          DocumentosDeProcedimiento,
          AsyncValue<List<Documento>>,
          List<Documento>,
          FutureOr<List<Documento>>,
          String
        > {
  DocumentosDeProcedimientoFamily._()
    : super(
        retry: null,
        name: r'documentosDeProcedimientoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DocumentosDeProcedimientoProvider call(String procedimientoId) =>
      DocumentosDeProcedimientoProvider._(
        argument: procedimientoId,
        from: this,
      );

  @override
  String toString() => r'documentosDeProcedimientoProvider';
}

abstract class _$DocumentosDeProcedimiento
    extends $AsyncNotifier<List<Documento>> {
  late final _$args = ref.$arg as String;
  String get procedimientoId => _$args;

  FutureOr<List<Documento>> build(String procedimientoId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Documento>>, List<Documento>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Documento>>, List<Documento>>,
              AsyncValue<List<Documento>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
