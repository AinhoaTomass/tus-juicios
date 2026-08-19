/// Datos del despacho, para que aparezcan como emisor en el PDF de las
/// facturas. Se guardan en Supabase, ligados al usuario.
class DatosDespacho {
  const DatosDespacho({this.nombre = '', this.nifCif = '', this.direccion = ''});

  final String nombre;
  final String nifCif;
  final String direccion;

  bool get estaCompleto => nombre.isNotEmpty && nifCif.isNotEmpty;

  DatosDespacho copyWith({String? nombre, String? nifCif, String? direccion}) {
    return DatosDespacho(
      nombre: nombre ?? this.nombre,
      nifCif: nifCif ?? this.nifCif,
      direccion: direccion ?? this.direccion,
    );
  }
}
