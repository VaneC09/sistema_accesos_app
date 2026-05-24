// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : app_routes.dart
// Módulo    : core/config
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Rutas centralizadas de la aplicación — MPF-OMEGA-04 §6.5
// =============================================================================

class AppRoutes {
  AppRoutes._();

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String loginVigilante = '/login-vigilante';
  static const String home = '/home';

  // ── Solicitudes ───────────────────────────────────────────────────────────
  static const String nuevaSolicitud = '/solicitudes/nueva';
  static const String misSolicitudes = '/solicitudes/mis-solicitudes';
  static const String detalleSolicitud = '/solicitudes/detalle';

  // ── Autorización ──────────────────────────────────────────────────────────
  static const String autorizaciones = '/autorizaciones';
  static const String detalleAutorizacion = '/autorizaciones/detalle';

  // ── QR ────────────────────────────────────────────────────────────────────
  static const String detalleQr = '/qr/detalle';

  // ── Control de acceso (vigilante) ─────────────────────────────────────────
  static const String escaner = '/acceso/escaner';
  static const String visitasHoy = '/acceso/visitas-hoy';

  // ── Confirmación de visita ────────────────────────────────────────────────
  static const String confirmacionVisita = '/visita/confirmacion';
}