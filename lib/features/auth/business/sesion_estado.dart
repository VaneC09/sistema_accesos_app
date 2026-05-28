// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : sesion_estado.dart
// Módulo    : features/auth/business
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.1.0
// Descripción: Enum unificado de estado de sesión del vigilante.
//              REEMPLAZA el archivo sesion_estado.dart existente.
//              Corrige esValida (estaba invertido) y añade mensajes.
// =============================================================================

import '../../../core/config/app_config.dart';

enum SesionEstado {
  /// Sesión activa y dentro de los límites.
  valida,

  /// Pasaron más de [AppConfig.minutosInactividad] min sin actividad.
  inactividad,

  /// Pasaron más de [AppConfig.horasJornadaLaboral] horas desde el inicio.
  jornadaFinalizada,

  /// No hay datos de sesión guardados.
  invalida;

  // ── Helpers ────────────────────────────────────────────────────────────────
  /// true solo cuando la sesión está activa.
  bool get esValida => this == SesionEstado.valida;

  /// Mensaje legible para mostrar al vigilante en el SnackBar.
  String get mensajeUsuario {
    switch (this) {
      case SesionEstado.valida:
        return '';
      case SesionEstado.inactividad:
        return 'Tu sesión se cerró por inactividad '
            '(${AppConfig.minutosInactividad} min). '
            'Vuelve a identificarte.';
      case SesionEstado.jornadaFinalizada:
        return 'Tu jornada de ${AppConfig.horasJornadaLaboral} h ha '
            'finalizado. Vuelve a identificarte al inicio del siguiente turno.';
      case SesionEstado.invalida:
        return 'Sesión no encontrada. Vuelve a identificarte.';
    }
  }
}
