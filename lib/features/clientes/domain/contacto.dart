/// Teléfono en formato internacional sin "+" para enlaces wa.me. Un número
/// español de 9 cifras sin prefijo se asume +34; uno con "+" o "00" delante
/// se respeta.
String numeroWhatsApp(String telefono) {
  var digitos = telefono.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.startsWith('00')) digitos = digitos.substring(2);
  if (!telefono.trim().startsWith('+') && digitos.length == 9) {
    digitos = '34$digitos';
  }
  return digitos;
}
