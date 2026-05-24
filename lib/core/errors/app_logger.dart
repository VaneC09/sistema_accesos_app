// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_logger.dart
// Módulo    : core/errors
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Sistema centralizado de logs — MPF-OMEGA-04 §6.6
// =============================================================================

import 'package:flutter/foundation.dart';

enum LogLevel { info, warning, error, critical }

class AppLogger {
  AppLogger._();

  // Registra evento informativo normal
  static void info(String modulo, String descripcion) {
    _registrar(LogLevel.info, modulo, descripcion);
  }

  // Registra situación anómala no crítica
  static void warning(String modulo, String descripcion) {
    _registrar(LogLevel.warning, modulo, descripcion);
  }

  // Registra fallo controlado que afecta funcionalidad
  static void error(String modulo, String descripcion) {
    _registrar(LogLevel.error, modulo, descripcion);
  }

  // Registra fallo que compromete estabilidad o seguridad
  static void critical(String modulo, String descripcion) {
    _registrar(LogLevel.critical, modulo, descripcion);
  }

  static void _registrar(
      LogLevel nivel,
      String modulo,
      String descripcion,
      ) {
    // En producción solo se muestran WARNING, ERROR y CRITICAL
    if (!kDebugMode && nivel == LogLevel.info) return;

    final ahora = DateTime.now().toIso8601String();
    final nivelTexto = _nivelTexto(nivel);

    // No se registran datos sensibles: tokens, contraseñas, datos personales
    final mensaje = '[$ahora] [$nivelTexto] [$modulo] $descripcion';

    if (kDebugMode) {
      debugPrint(mensaje);
    }

    // TODO: En producción integrar con servicio de logs remoto
  }

  static String _nivelTexto(LogLevel nivel) {
    switch (nivel) {
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.critical:
        return 'CRITICAL';
    }
  }
}