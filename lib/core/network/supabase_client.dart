import 'package:supabase_flutter/supabase_flutter.dart';

/// Credenciales inyectadas en build/run con:
///   --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static Future<void> init() {
    return Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

SupabaseClient get supabase => Supabase.instance.client;
