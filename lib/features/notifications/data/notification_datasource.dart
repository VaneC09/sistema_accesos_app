// =============================================================================
// Proyecto  : Sistema de Gestión de Accos y Visitas
// Archivo   : notification_datasource.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.0.0
// Descripción: Fuente de datos real de notificaciones — RF-023
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'notification_model.dart';

class NotificationDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'NOTIFICATION_DATASOURCE';

  NotificationDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<List<NotificationModel>> obtenerNotificaciones() async {
    AppLogger.info(_modulo, 'Obteniendo notificaciones reales desde API');

    final respuesta = await _apiClient.get('/notificaciones');

    final data = respuesta.data as Map<String, dynamic>;
    final paginacion = data['data'] as Map<String, dynamic>;
    final lista = paginacion['data'] as List<dynamic>? ?? [];

    return lista
        .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
        .toList();
  }
}