// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_repository.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.0.0
// Descripción: Repositorio de notificaciones — RF-023
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'notification_model.dart';

class NotificationRepository {
  static const String _modulo = 'NOTIFICATION_REPOSITORY';
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // ── Obtener todas las notificaciones del usuario autenticado ──────────────

  Future<List<NotificationModel>> obtenerNotificaciones() async {
    try {
      final respuesta = await _apiClient.get('/notificaciones');
      final data = respuesta.data as Map<String, dynamic>;
      final lista = data['data'] as List<dynamic>? ?? [];

      return lista
          .map((n) =>
          NotificationModel.fromJson(n as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener notificaciones: $e');
      rethrow;
    }
  }

  // ── Marcar notificación individual como leída ─────────────────────────────

  Future<void> marcarLeida(String idNotificacion) async {
    try {
      await _apiClient.patch('/notificaciones/$idNotificacion/leer');
      AppLogger.info(_modulo, 'Notificación $idNotificacion marcada como leída');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar notificación: $e');
      rethrow;
    }
  }

  // ── Marcar todas como leídas ──────────────────────────────────────────────

  Future<void> marcarTodasLeidas() async {
    try {
      await _apiClient.patch('/notificaciones/leer-todas');
      AppLogger.info(_modulo, 'Todas las notificaciones marcadas como leídas');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar todas: $e');
      rethrow;
    }
  }

  // ── Extender QR desde el lado del anfitrión ───────────────────────────────
  // Llama a POST /api/solicitudes/{id}/extender-qr
  // Este endpoint actualiza vigencia_final en la BD para permitir el acceso.

  Future<void> extenderQr(int idSolicitud) async {
    try {
      await _apiClient.post('/solicitudes/$idSolicitud/extender-qr');
      AppLogger.info(
          _modulo, 'QR extendido para solicitud $idSolicitud');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al extender QR: $e');
      rethrow;
    }
  }
}