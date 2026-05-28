// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_datasource.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.0.0
// Descripción: Fuente de datos para visita espontánea de consulta — RF-014
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'consulta_model.dart';

class ConsultaDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'CONSULTA_DATASOURCE';

  ConsultaDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  Future<ConsultaResponseModel> registrarConsulta(
      ConsultaRequestModel consulta,
      ) async {
    AppLogger.info(_modulo, 'Registrando visita espontánea de consulta');

    final respuesta = await _apiClient.post(
      '/vigilante/consulta',
      datos: consulta.toJson(),
    );

    return ConsultaResponseModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }
}