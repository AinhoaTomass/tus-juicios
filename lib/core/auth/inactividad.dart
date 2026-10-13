import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/supabase_client.dart';

/// Tiempo sin tocar la app tras el que se cierra la sesión.
const tiempoMaximoInactividad = Duration(minutes: 15);

const _claveUltimaActividad = 'ultima_actividad_ms';

/// Cada cuánto, como mucho, se guarda en disco la última actividad
/// (para no escribir en cada toque).
const _intervaloGuardado = Duration(seconds: 30);

/// Se pone a `true` cuando la sesión se cierra por inactividad, para que
/// la pantalla de login pueda explicarlo.
final ValueNotifier<bool> sesionCerradaPorInactividad = ValueNotifier(false);

/// Al arrancar la app: si hay sesión guardada pero la última actividad
/// registrada es más antigua que [tiempoMaximoInactividad], se cierra.
/// Cubre el caso de cerrar la app (o la pestaña) y volver al rato.
Future<void> cerrarSesionSiCaducada() async {
  if (supabase.auth.currentSession == null) return;
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_claveUltimaActividad);
  if (ms == null) return;
  final ultima = DateTime.fromMillisecondsSinceEpoch(ms);
  if (DateTime.now().difference(ultima) > tiempoMaximoInactividad) {
    await _cerrarSesion();
  }
}

Future<void> _cerrarSesion() async {
  sesionCerradaPorInactividad.value = true;
  await supabase.auth.signOut();
}

/// Envuelve la app y cierra la sesión tras [tiempoMaximoInactividad] sin
/// toques ni teclas, también si la app ha estado en segundo plano ese tiempo.
class VigilanteInactividad extends StatefulWidget {
  const VigilanteInactividad({super.key, required this.child});

  final Widget child;

  @override
  State<VigilanteInactividad> createState() => _VigilanteInactividadState();
}

class _VigilanteInactividadState extends State<VigilanteInactividad>
    with WidgetsBindingObserver {
  Timer? _temporizador;
  DateTime _ultimaActividad = DateTime.now();
  DateTime? _ultimoGuardado;
  late final StreamSubscription _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(_alPulsarTecla);
    _authSub = supabase.auth.onAuthStateChange.listen((_) => _registrarActividad());
    _registrarActividad();
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _authSub.cancel();
    HardwareKeyboard.instance.removeHandler(_alPulsarTecla);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _alPulsarTecla(KeyEvent _) {
    _registrarActividad();
    return false;
  }

  void _registrarActividad() {
    _ultimaActividad = DateTime.now();
    _temporizador?.cancel();
    if (supabase.auth.currentSession == null) return;
    _temporizador = Timer(tiempoMaximoInactividad, _caducar);

    final ultimoGuardado = _ultimoGuardado;
    if (ultimoGuardado == null ||
        _ultimaActividad.difference(ultimoGuardado) > _intervaloGuardado) {
      _guardarUltimaActividad();
    }
  }

  Future<void> _guardarUltimaActividad() async {
    _ultimoGuardado = _ultimaActividad;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _claveUltimaActividad,
      _ultimaActividad.millisecondsSinceEpoch,
    );
  }

  void _caducar() {
    if (supabase.auth.currentSession == null) return;
    _cerrarSesion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // En segundo plano el temporizador puede no haberse disparado.
        if (DateTime.now().difference(_ultimaActividad) >
            tiempoMaximoInactividad) {
          _caducar();
        } else {
          _registrarActividad();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _guardarUltimaActividad();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _registrarActividad(),
      onPointerSignal: (_) => _registrarActividad(),
      child: widget.child,
    );
  }
}
