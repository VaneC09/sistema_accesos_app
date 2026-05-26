// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_datasource.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos mock de autorización — RF-019, RF-020
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
    final respuesta = await _apiClient.get('/solicitudes/pendientes');
    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista.map((s) => AuthorizationModel.fromJson(s as Map<String, dynamic>)).toList();
  }

  Future<AuthorizationModel> obtenerDetalle(int idSolicitud) async {
    final respuesta = await _apiClient.get('/solicitudes/$idSolicitud');
    return AuthorizationModel.fromJson(respuesta.data as Map<String, dynamic>);
  }

  Future<void> autorizar(int idSolicitud) async {
    AppLogger.info(_modulo, 'Autorizando solicitud: $idSolicitud');
    await _apiClient.post('/solicitudes/$idSolicitud/autorizar');
  }

  Future<void> rechazar(int idSolicitud, String motivo) async {
    AppLogger.info(_modulo, 'Rechazando solicitud: $idSolicitud');
    await _apiClient.post(
      '/solicitudes/$idSolicitud/rechazar',
      datos: {'motivo': motivo},
    );
  }
}
