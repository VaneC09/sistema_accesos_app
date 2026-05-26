// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_datasource.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'visit_request_model.dart';

class VisitRequestDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'VISIT_REQUEST_DATASOURCE';

  VisitRequestDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<VisitRequestModel> crearSolicitud(VisitRequestModel solicitud) async {
    AppLogger.info(_modulo, 'Creando solicitud de visita');
    final respuesta = await _apiClient.post('/solicitudes', datos: solicitud.toJson());
    return VisitRequestModel.fromJson(respuesta.data as Map<String, dynamic>);
  }

  Future<List<VisitRequestModel>> obtenerMisSolicitudes({
    String? estado, DateTime? fechaInicio, DateTime? fechaFin,
  }) async {
    final parametros = <String, dynamic>{};
    if (estado != null) parametros['estado'] = estado;
    if (fechaInicio != null) parametros['fecha_inicio'] = fechaInicio.toIso8601String();
    if (fechaFin != null) parametros['fecha_fin'] = fechaFin.toIso8601String();
    final respuesta = await _apiClient.get('/solicitudes/mis-solicitudes', parametros: parametros);
    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista.map((s) => VisitRequestModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<VisitRequestModel> obtenerDetalle(int idSolicitud) async {
    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');
    return VisitRequestModel.fromJson(respuesta.data as Map<String, dynamic>);
  }

  Future<void> cancelarSolicitud(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/cancelar');
  }

  Future<List<CatalogoModel>> obtenerTiposVisita() async {
    final respuesta = await _apiClient.get('/catalogos/tipos-visita');
    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista.map((t) => CatalogoModel.fromJson(t as Map<String, dynamic>)).toList();
  }

  Future<List<CatalogoModel>> obtenerDepartamentos() async {
    final respuesta = await _apiClient.get('/catalogos/departamentos');
    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista.map((d) => CatalogoModel.fromJson(d as Map<String, dynamic>)).toList();
  }

  Future<void> enviarQr(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/enviar-qr');
  }

  Future<void> reenviarQr(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/reenviar-qr');
  }

  Future<void> extenderQr(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/extender-qr');
  }
}
