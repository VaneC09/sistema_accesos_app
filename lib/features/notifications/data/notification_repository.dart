// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_repository.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.3.0
// Descripción: Repositorio de notificaciones — RF-023
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/connection/api_response_helper.dart';
import '../../../core/constants/filtro_estado_solicitud.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import '../../../core/models/paginated_result.dart';
import '../../../core/utils/paginacion_local.dart';
import '../../../core/utils/paginacion_remota.dart';
import 'notification_model.dart';

class NotificationRepository {
  static const String _modulo = 'NOTIFICATION_REPOSITORY';
  final ApiClient _apiClient;

  NotificationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<PaginatedResult<NotificationModel>> obtenerNotificaciones({
    int pagina = 1,
    String? estado,
  }) async {
    try {
      if (!_tieneFiltroEstado(estado)) {
        return _obtenerPaginaNotificaciones(
          ruta: '/notificaciones',
          pagina: pagina,
          etiqueta: 'GET /notificaciones',
        );
      }

      final todas = await PaginacionRemota.recopilarPaginas(
        obtenerPagina: (p) => _obtenerPaginaNotificaciones(
          ruta: '/notificaciones',
          pagina: p,
          etiqueta: 'GET /notificaciones',
        ),
      );

      final filtradas = todas
          .where((n) => _coincideFiltroNotificacion(estado!, n))
          .toList();

      return PaginacionLocal.paginar(filtradas, pagina: pagina);
    } on NotFoundException {
      AppLogger.error(
        _modulo,
        'Ruta GET /notificaciones no encontrada — verifique que el backend '
        'esté activo y baseUrl en app_config.dart',
      );
      rethrow;
    } catch (e, st) {
      AppLogger.error(_modulo, 'Error al obtener notificaciones: $e\n$st');
      rethrow;
    }
  }

  Future<PaginatedResult<NotificationModel>> obtenerNotificacionesVigilante({
    required String telefono,
    int pagina = 1,
    String? estado,
  }) async {
    try {
      if (!_tieneFiltroEstado(estado)) {
        return _obtenerPaginaNotificaciones(
          ruta: '/vigilante/notificaciones',
          pagina: pagina,
          etiqueta: 'GET /vigilante/notificaciones',
          parametrosExtra: {'telefono': telefono},
        );
      }

      final todas = await PaginacionRemota.recopilarPaginas(
        obtenerPagina: (p) => _obtenerPaginaNotificaciones(
          ruta: '/vigilante/notificaciones',
          pagina: p,
          etiqueta: 'GET /vigilante/notificaciones',
          parametrosExtra: {'telefono': telefono},
        ),
      );

      final filtradas = todas
          .where((n) => _coincideFiltroNotificacion(estado!, n))
          .toList();

      return PaginacionLocal.paginar(filtradas, pagina: pagina);
    } catch (e, st) {
      AppLogger.error(
        _modulo,
        'Error al obtener notificaciones vigilante: $e\n$st',
      );
      rethrow;
    }
  }

  bool _tieneFiltroEstado(String? estado) {
    return estado != null && estado != FiltroEstadoSolicitud.todos;
  }

  Future<PaginatedResult<NotificationModel>> _obtenerPaginaNotificaciones({
    required String ruta,
    required int pagina,
    required String etiqueta,
    Map<String, dynamic>? parametrosExtra,
  }) async {
    final parametros = <String, dynamic>{'page': pagina};
    if (parametrosExtra != null) parametros.addAll(parametrosExtra);

    final respuesta = await _apiClient.get(ruta, parametros: parametros);
    return _mapearNotificaciones(respuesta.data, etiqueta: etiqueta);
  }

  PaginatedResult<NotificationModel> _mapearNotificaciones(
    dynamic body, {
    required String etiqueta,
  }) {
    final mapas = ApiResponseHelper.extraerMapas(body, etiqueta: etiqueta);
    final items = mapas.map(NotificationModel.fromJson).toList();

    final paginacion = ApiResponseHelper.extraerPaginacion(
      body,
      cantidadItems: items.length,
    );

    return PaginatedResult(items: items, paginacion: paginacion);
  }

  bool _coincideFiltroNotificacion(String chip, NotificationModel notificacion) {
    return FiltroEstadoSolicitud.coincideEstado(
      chip,
      notificacion.estadoInferido,
    );
  }

  Future<void> marcarLeida(String idNotificacion) async {
    try {
      await _apiClient.post('/notificaciones/$idNotificacion/leida');
      AppLogger.info(_modulo, 'Notificación $idNotificacion marcada como leída');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar notificación: $e');
      rethrow;
    }
  }

  Future<void> marcarLeidaVigilante({
    required String idNotificacion,
    required String telefono,
  }) async {
    try {
      await _apiClient.post(
        '/vigilante/notificaciones/$idNotificacion/leida',
        datos: {'telefono': telefono},
      );
      AppLogger.info(
        _modulo,
        'Notificación vigilante $idNotificacion marcada como leída',
      );
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar notificación vigilante: $e');
      rethrow;
    }
  }

  Future<void> marcarTodasLeidas() async {
    try {
      await _apiClient.post('/notificaciones/todas-leidas');
      AppLogger.info(_modulo, 'Todas las notificaciones marcadas como leídas');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al marcar todas: $e');
      rethrow;
    }
  }

  Future<void> extenderQr(int idSolicitud) async {
    try {
      await _apiClient.post('/solicitudes/$idSolicitud/extender-qr');
      AppLogger.info(_modulo, 'QR extendido para solicitud $idSolicitud');
    } catch (e) {
      AppLogger.error(_modulo, 'Error al extender QR: $e');
      rethrow;
    }
  }
}
