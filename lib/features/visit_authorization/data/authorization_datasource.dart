// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_datasource.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de autorización — RF-019, RF-020
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'authorization_model.dart';

class AuthorizationDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'AUTHORIZATION_DATASOURCE';

  AuthorizationDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<List<AuthorizationModel>> obtenerPendientes() async {
    AppLogger.info(_modulo, 'Obteniendo solicitudes pendientes');

    final respuesta = await _apiClient.get('/autorizador/solicitudes');

    final data = respuesta.data as Map<String, dynamic>;
    final paginacion = data['data'] as Map<String, dynamic>;
    final lista = paginacion['data'] as List<dynamic>? ?? [];

    return lista
        .map((s) => AuthorizationModel.fromJson(s as Map<String, dynamic>))
        .toList();
  }

  Future<AuthorizationModel> obtenerDetalle(int idSolicitud) async {
    AppLogger.info(_modulo, 'Obteniendo detalle de solicitud: $idSolicitud');

    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');

    final data = respuesta.data as Map<String, dynamic>;
    final solicitudJson = data['data'] as Map<String, dynamic>;

    return AuthorizationModel.fromJson(solicitudJson);
  }

  Future<void> autorizar(int idSolicitud) async {
    AppLogger.info(_modulo, 'Autorizando solicitud: $idSolicitud');

    await _apiClient.post('/autorizador/$idSolicitud/autorizar');
  }

  Future<void> rechazar(int idSolicitud, String motivo) async {
    AppLogger.info(_modulo, 'Rechazando solicitud: $idSolicitud');

    await _apiClient.post(
      '/autorizador/$idSolicitud/rechazar',
      datos: {
        'motivo': motivo,
      },
    );
  }
}