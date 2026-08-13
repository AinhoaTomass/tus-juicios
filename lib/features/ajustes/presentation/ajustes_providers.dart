import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/recordatorios_config.dart';

part 'ajustes_providers.g.dart';

const _claveCitasActivo = 'recordatorios_citas_activo';
const _claveCitasDiasAntes = 'recordatorios_citas_dias_antes';
const _claveCitasHora = 'recordatorios_citas_hora';
const _claveProcedimientosActivo = 'recordatorios_procedimientos_activo';
const _claveProcedimientosDiasAntes = 'recordatorios_procedimientos_dias_antes';
const _claveProcedimientosHora = 'recordatorios_procedimientos_hora';

@riverpod
class RecordatoriosConfigNotifier extends _$RecordatoriosConfigNotifier {
  @override
  Future<RecordatoriosConfig> build() async {
    final prefs = await SharedPreferences.getInstance();
    return RecordatoriosConfig(
      citasActivo: prefs.getBool(_claveCitasActivo) ?? true,
      citasDiasAntes: prefs.getInt(_claveCitasDiasAntes) ?? 1,
      citasHora: prefs.getInt(_claveCitasHora) ?? 20,
      procedimientosActivo: prefs.getBool(_claveProcedimientosActivo) ?? true,
      procedimientosDiasAntes: prefs.getInt(_claveProcedimientosDiasAntes) ?? 3,
      procedimientosHora: prefs.getInt(_claveProcedimientosHora) ?? 9,
    );
  }

  Future<void> actualizar(RecordatoriosConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveCitasActivo, config.citasActivo);
    await prefs.setInt(_claveCitasDiasAntes, config.citasDiasAntes);
    await prefs.setInt(_claveCitasHora, config.citasHora);
    await prefs.setBool(_claveProcedimientosActivo, config.procedimientosActivo);
    await prefs.setInt(_claveProcedimientosDiasAntes, config.procedimientosDiasAntes);
    await prefs.setInt(_claveProcedimientosHora, config.procedimientosHora);
    state = AsyncData(config);
  }
}
