// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eventos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventoRepository)
final eventoRepositoryProvider = EventoRepositoryProvider._();

final class EventoRepositoryProvider
    extends
        $FunctionalProvider<
          EventoRepository,
          EventoRepository,
          EventoRepository
        >
    with $Provider<EventoRepository> {
  EventoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventoRepositoryHash();

  @$internal
  @override
  $ProviderElement<EventoRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EventoRepository create(Ref ref) {
    return eventoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventoRepository>(value),
    );
  }
}

String _$eventoRepositoryHash() => r'6ec062cfe2f4dcc33a70961b4439924e176eb44a';

@ProviderFor(EventosLista)
final eventosListaProvider = EventosListaProvider._();

final class EventosListaProvider
    extends $AsyncNotifierProvider<EventosLista, List<Evento>> {
  EventosListaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventosListaProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventosListaHash();

  @$internal
  @override
  EventosLista create() => EventosLista();
}

String _$eventosListaHash() => r'044a478efcba82071f2d1109c4707f59cc0c4549';

abstract class _$EventosLista extends $AsyncNotifier<List<Evento>> {
  FutureOr<List<Evento>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Evento>>, List<Evento>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Evento>>, List<Evento>>,
              AsyncValue<List<Evento>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(eventoPorId)
final eventoPorIdProvider = EventoPorIdFamily._();

final class EventoPorIdProvider
    extends $FunctionalProvider<AsyncValue<Evento>, Evento, FutureOr<Evento>>
    with $FutureModifier<Evento>, $FutureProvider<Evento> {
  EventoPorIdProvider._({
    required EventoPorIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventoPorIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventoPorIdHash();

  @override
  String toString() {
    return r'eventoPorIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Evento> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Evento> create(Ref ref) {
    final argument = this.argument as String;
    return eventoPorId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventoPorIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventoPorIdHash() => r'87806339a95ebc27f9f975f11de397e7acd7dbe7';

final class EventoPorIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Evento>, String> {
  EventoPorIdFamily._()
    : super(
        retry: null,
        name: r'eventoPorIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventoPorIdProvider call(String id) =>
      EventoPorIdProvider._(argument: id, from: this);

  @override
  String toString() => r'eventoPorIdProvider';
}
