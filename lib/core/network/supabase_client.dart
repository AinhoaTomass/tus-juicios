import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Credenciales inyectadas en build/run con:
///   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static Future<void> init() async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
    supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        isPasswordRecovery.value = true;
      }
    });
  }
}

SupabaseClient get supabase => Supabase.instance.client;

/// Se pone a `true` cuando Supabase emite el evento `passwordRecovery`
/// (el usuario ha tocado el enlace de "olvidé mi contraseña" del email).
/// El router lo usa para forzar la navegación a la pantalla de nueva
/// contraseña en vez del flujo normal de login.
final ValueNotifier<bool> isPasswordRecovery = ValueNotifier(false);
