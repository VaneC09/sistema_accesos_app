// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_datasource.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de solicitudes de visita — RF-013, RF-014
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'visit_request_model.dart';

class VisitRequestDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'VISIT_REQUEST_DATASOURCE';

  VisitRequestDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Crear solicitud de visita
  Future<VisitRequestModel> crearSolicitud(
      VisitRequestModel solicitud,
      ) async {
    AppLogger.info(_modulo, 'Creando solicitud de visita');

    final respuesta = await _apiClient.post(
      '/solicitudes',
      datos: solicitud.toJson(),
    );

    AppLogger.info(_modulo, 'Solicitud creada exitosamente');
    return VisitRequestModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Obtener mis solicitudes
  Future<List<VisitRequestModel>> obtenerMisSolicitudes({
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo mis solicitudes');

    final parametros = <String, dynamic>{};
    if (estado != null) parametros['estado'] = estado;
    if (fechaInicio != null) {
      parametros['fecha_inicio'] = fechaInicio.toIso8601String();
    }
    if (fechaFin != null) {
      parametros['fecha_fin'] = fechaFin.toIso8601String();
    }

    final respuesta = await _apiClient.get(
      '/solicitudes/mis-solicitudes',
      parametros: parametros,
    );

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((s) => VisitRequestModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  // Obtener detalle de solicitud
  Future<VisitRequestModel> obtenerDetalle(int idSolicitud) async {
    AppLogger.info(_modulo, 'Obteniendo detalle solicitud: $idSolicitud');

    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');

    return VisitRequestModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Cancelar solicitud
  Future<void> cancelarSolicitud(int idSolicitud) async {
    AppLogger.info(_modulo, 'Cancelando solicitud: $idSolicitud');

    await _apiClient.post('/solicitudes/$idSolicitud/cancelar');

    AppLogger.info(_modulo, 'Solicitud cancelada: $idSolicitud');
  }

  // Obtener catálogo de tipos de visita
  Future<List<CatalogoModel>> obtenerTiposVisita() async {
    AppLogger.info(_modulo, 'Obteniendo tipos de visita');

    final respuesta = await _apiClient.get('/catalogos/tipos-visita');

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((t) => CatalogoModel.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  // Obtener catálogo de departamentos
  Future<List<CatalogoModel>> obtenerDepartamentos() async {
    AppLogger.info(_modulo, 'Obteniendo departamentos');

    final respuesta = await _apiClient.get('/catalogos/departamentos');

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((d) => CatalogoModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // Enviar QR al visitante
  Future<void> enviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Enviando QR solicitud: $idSolicitud');

    await _apiClient.post('/solicitudes/$idSolicitud/enviar-qr');

    AppLogger.info(_modulo, 'QR enviado: $idSolicitud');
  }

  // Reenviar QR
  Future<void> reenviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Reenviando QR solicitud: $idSolicitud');

    await _apiClient.post('/solicitudes/$idSolicitud/reenviar-qr');

    AppLogger.info(_modulo, 'QR reenviado: $idSolicitud');
  }

  // Extender vigencia del QR
  Future<void> extenderQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Extendiendo QR solicitud: $idSolicitud');

    await _apiClient.post('/solicitudes/$idSolicitud/extender-qr');

    AppLogger.info(_modulo, 'QR extendido: $idSolicitud');
  }
}