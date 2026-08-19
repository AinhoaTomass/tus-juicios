import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/supabase_client.dart';
import '../domain/datos_despacho.dart';
import '../domain/recordatorios_config.dart';

part 'ajustes_providers.g.dart';

/// Todos los ajustes (tema, recordatorios, datos del despacho) viven en una
/// única fila de `ajustes` (una por usuario, protegida por RLS con
/// `owner_id = auth.uid()`), para que viajen entre dispositivos con la
/// cuenta en vez de quedarse fijados a este aparato.
Future<Map<String, dynamic>> _leerFila() async {
  final fila = await supabase.from('ajustes').select().maybeSingle();
  return fila ?? const {};
}

/// Inserta la fila si no existe, o actualiza solo las columnas indicadas.
Future<void> _guardarFila(Map<String, dynamic> cambios) {
  return supabase.from('ajustes').upsert({
    'owner_id': supabase.auth.currentUser!.id,
    ...cambios,
  });
}

@riverpod
class TemaModoNotifier extends _$TemaModoNotifier {
  @override
  Future<ThemeMode> build() async {
    final fila = await _leerFila();
    final guardado = fila['tema_modo'] as String?;
    return guardado == null ? ThemeMode.system : ThemeMode.values.byName(guardado);
  }

  Future<void> actualizar(ThemeMode modo) async {
    state = AsyncData(modo);
    await _guardarFila({'tema_modo': modo.name});
  }
}

@riverpod
class RecordatoriosConfigNotifier extends _$RecordatoriosConfigNotifier {
  @override
  Future<RecordatoriosConfig> build() async {
    final fila = await _leerFila();
    return RecordatoriosConfig(
      citasActivo: fila['recordatorios_citas_activo'] as bool? ?? true,
      citasDiasAntes: fila['recordatorios_citas_dias_antes'] as int? ?? 1,
      citasHora: fila['recordatorios_citas_hora'] as int? ?? 20,
      procedimientosActivo: fila['recordatorios_procedimientos_activo'] as bool? ?? true,
      procedimientosDiasAntes: fila['recordatorios_procedimientos_dias_antes'] as int? ?? 3,
      procedimientosHora: fila['recordatorios_procedimientos_hora'] as int? ?? 9,
    );
  }

  Future<void> actualizar(RecordatoriosConfig config) async {
    state = AsyncData(config);
    await _guardarFila({
      'recordatorios_citas_activo': config.citasActivo,
      'recordatorios_citas_dias_antes': config.citasDiasAntes,
      'recordatorios_citas_hora': config.citasHora,
      'recordatorios_procedimientos_activo': config.procedimientosActivo,
      'recordatorios_procedimientos_dias_antes': config.procedimientosDiasAntes,
      'recordatorios_procedimientos_hora': config.procedimientosHora,
    });
  }
}

@riverpod
class DatosDespachoNotifier extends _$DatosDespachoNotifier {
  @override
  Future<DatosDespacho> build() async {
    final fila = await _leerFila();
    return DatosDespacho(
      nombre: fila['despacho_nombre'] as String? ?? '',
      nifCif: fila['despacho_nif_cif'] as String? ?? '',
      direccion: fila['despacho_direccion'] as String? ?? '',
    );
  }

  Future<void> actualizar(DatosDespacho datos) async {
    state = AsyncData(datos);
    await _guardarFila({
      'despacho_nombre': datos.nombre,
      'despacho_nif_cif': datos.nifCif,
      'despacho_direccion': datos.direccion,
    });
  }
}
