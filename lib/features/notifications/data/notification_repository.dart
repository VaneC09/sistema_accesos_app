// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_repository.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.0.0
// Descripción: Repositorio real de notificaciones — RF-023
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'notification_datasource.dart';
import 'notification_model.dart';

class NotificationRepository {
  final NotificationDatasource _datasource;
  static const String _modulo = 'NOTIFICATION_REPOSITORY';

  NotificationRepository({NotificationDatasource? datasource})
      : _datasource = datasource ?? NotificationDatasource();

  Future<List<NotificationModel>> obtenerNotificaciones() async {
    try {
      return await _datasource.obtenerNotificaciones();
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener notificaciones: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener las notificaciones. Intente nuevamente',
      );
    }
  }
}