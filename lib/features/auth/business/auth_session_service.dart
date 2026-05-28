// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_session_service.dart
// Módulo    : features/auth/business
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.2.0
// Descripción: Servicio de sesión del vigilante.
//              Usa SesionEstado del proyecto (sesion_estado.dart).
//              Dos límites independientes:
//                1. Inactividad  → AppConfig.minutosInactividad (30 min)
//                2. Jornada      → AppConfig.horasJornadaLaboral (7 h)
// =============================================================================

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/app_logger.dart';
import 'sesion_estado.dart';

class AuthSessionService {
  static const String _modulo = 'AUTH_SESSION_SERVICE';
  static const String _claveUltimaActividad = 'vigilante_ultima_actividad_ts';

  final FlutterSecureStorage _storage;

  AuthSessionService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ── Inicio de jornada ─────────────────────────────────────────────────────
  /// Llama UNA SOLA VEZ al hacer login. Fija inicio de jornada.
  Future<void> iniciarJornada() async {
    final ahora = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: AppConfig.claveInicioJornada, value: ahora);
    await _storage.write(key: _claveUltimaActividad, value: ahora);
    AppLogger.info(_modulo, 'Jornada iniciada: $ahora');
  }

  // ── Registrar actividad ───────────────────────────────────────────────────
  /// Reinicia el contador de INACTIVIDAD (no afecta el límite de jornada).
  Future<void> registrarActividad() async {
    final ahora = DateTime.now().millisecondsSinceEpoch.toString();
    await _storage.write(key: _claveUltimaActividad, value: ahora);
  }

  // ── Verificar sesión ──────────────────────────────────────────────────────
  /// Evalúa inactividad primero, luego jornada.
  Future<SesionEstado> esSesionValida() async {
    try {
      // 1. Sin datos → inválida
      final rawActividad = await _storage.read(key: _claveUltimaActividad);
      if (rawActividad == null) return SesionEstado.invalida;

      // 2. Inactividad
      final ultimaActividad =
      DateTime.fromMillisecondsSinceEpoch(int.parse(rawActividad));
      final minutosInactivo =
          DateTime.now().difference(ultimaActividad).inMinutes;

      if (minutosInactivo >= AppConfig.minutosInactividad) {
        AppLogger.warning(_modulo,
            'Expirada por inactividad: $minutosInactivo min');
        return SesionEstado.inactividad;
      }

      // 3. Jornada laboral
      final rawJornada =
      await _storage.read(key: AppConfig.claveInicioJornada);
      if (rawJornada == null) {
        // Sin timestamp de jornada (migración) → fijarlo y continuar
        await _storage.write(
          key: AppConfig.claveInicioJornada,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );
        return SesionEstado.valida;
      }

      final inicioJornada =
      DateTime.fromMillisecondsSinceEpoch(int.parse(rawJornada));
      final horasTranscurridas =
          DateTime.now().difference(inicioJornada).inHours;

      if (horasTranscurridas >= AppConfig.horasJornadaLaboral) {
        AppLogger.warning(_modulo,
            'Expirada por jornada: $horasTranscurridas h');
        return SesionEstado.jornadaFinalizada;
      }

      return SesionEstado.valida;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al verificar sesión: $e');
      return SesionEstado.invalida;
    }
  }

  // ── Limpiar ───────────────────────────────────────────────────────────────
  Future<void> limpiarSesion() async {
    await _storage.delete(key: _claveUltimaActividad);
    await _storage.delete(key: AppConfig.claveInicioJornada);
    AppLogger.info(_modulo, 'Sesión vigilante limpiada');
  }
}