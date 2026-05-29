// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_datasource.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.1
// Cambio    : Agrega consumo de endpoint para enviar QR al visitante.
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

    final respuesta = await _apiClient.post(
      '/solicitudes',
      datos: solicitud.toJson(),
    );

    final data = respuesta.data as Map<String, dynamic>;
    final solicitudJson = data['data'] as Map<String, dynamic>;

    return VisitRequestModel.fromJson(solicitudJson);
  }

  Future<List<VisitRequestModel>> obtenerMisSolicitudes({
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final parametros = <String, dynamic>{};

    if (estado != null) parametros['estado'] = estado;
    if (fechaInicio != null) {
      parametros['fecha_inicio'] = fechaInicio.toIso8601String();
    }
    if (fechaFin != null) {
      parametros['fecha_fin'] = fechaFin.toIso8601String();
    }

    final respuesta = await _apiClient.get(
      '/solicitudes',
      parametros: parametros,
    );

    final data = respuesta.data as Map<String, dynamic>;
    final paginacion = data['data'] as Map<String, dynamic>;
    final lista = paginacion['data'] as List<dynamic>? ?? [];

    return lista
        .map((s) => VisitRequestModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<VisitRequestModel> obtenerDetalle(int idSolicitud) async {
    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');

    final data = respuesta.data as Map<String, dynamic>;
    final solicitudJson = data['data'] as Map<String, dynamic>;

    return VisitRequestModel.fromJson(solicitudJson);
  }

  Future<void> cancelarSolicitud(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/cancelar');
  }

  Future<List<CatalogoModel>> obtenerTiposVisita() async {
    return [
      const CatalogoModel(id: 1, nombre: 'Proveedor'),
      const CatalogoModel(id: 2, nombre: 'Institucional / Negocios'),
      const CatalogoModel(id: 3, nombre: 'Personal'),
    ];
  }

  Future<List<CatalogoModel>> obtenerDepartamentos() async {
    final respuesta = await _apiClient.get('/catalogos/departamentos');

    final data = respuesta.data;

    if (data is Map<String, dynamic>) {
      final lista = data['data'] as List<dynamic>? ?? [];
      return lista
          .map((d) => CatalogoModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    final lista = data as List<dynamic>? ?? [];

    return lista
        .map((d) => CatalogoModel.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  Future<String> enviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Enviando QR de solicitud: $idSolicitud');

    final respuesta = await _apiClient.post(
      '/solicitudes/$idSolicitud/enviar-qr',
    );

    final data = respuesta.data as Map<String, dynamic>;

    return data['message']?.toString() ??
        'QR enviado correctamente al visitante.';
  }

  Future<void> reenviarQr(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/reenviar-qr');
  }

  Future<void> extenderQr(int idSolicitud) async {
    await _apiClient.post('/solicitudes/$idSolicitud/extender-qr');
  }
}