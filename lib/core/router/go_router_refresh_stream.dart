import 'dart:async';

import 'package:flutter/foundation.dart';

/// Convierte un Stream (p.ej. `supabase.auth.onAuthStateChange`) en un
/// Listenable para que GoRouter reevalúe sus redirects cuando cambie.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
