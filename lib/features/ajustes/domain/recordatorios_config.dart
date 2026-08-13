/// Preferencias del usuario para los recordatorios locales (no se guardan
/// en Supabase: son de este dispositivo, no datos del despacho).
class RecordatoriosConfig {
  const RecordatoriosConfig({
    this.citasActivo = true,
    this.citasDiasAntes = 1,
    this.citasHora = 20,
    this.procedimientosActivo = true,
    this.procedimientosDiasAntes = 3,
    this.procedimientosHora = 9,
  });

  final bool citasActivo;
  final int citasDiasAntes;
  final int citasHora;

  final bool procedimientosActivo;
  final int procedimientosDiasAntes;
  final int procedimientosHora;

  RecordatoriosConfig copyWith({
    bool? citasActivo,
    int? citasDiasAntes,
    int? citasHora,
    bool? procedimientosActivo,
    int? procedimientosDiasAntes,
    int? procedimientosHora,
  }) {
    return RecordatoriosConfig(
      citasActivo: citasActivo ?? this.citasActivo,
      citasDiasAntes: citasDiasAntes ?? this.citasDiasAntes,
      citasHora: citasHora ?? this.citasHora,
      procedimientosActivo: procedimientosActivo ?? this.procedimientosActivo,
      procedimientosDiasAntes: procedimientosDiasAntes ?? this.procedimientosDiasAntes,
      procedimientosHora: procedimientosHora ?? this.procedimientosHora,
    );
  }
}
