// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : confirmation_datasource.dart
// Módulo    : features/visit_confirmation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de confirmación — RF-026, RF-051, RF-052
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'confirmation_model.dart';

class ConfirmationDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'CONFIRMATION_DATASOURCE';

  ConfirmationDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Confirmar llegada al área — RF-051
  Future<ConfirmationModel> confirmarLlegadaArea(int idSolicitud) async {
    AppLogger.info(_modulo, 'Confirmando llegada área: $idSolicitud');

    final respuesta = await _apiClient.post(
      '/visitas/$idSolicitud/confirmar-llegada',
    );

    return ConfirmationModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Confirmar salida del área — RF-052
  Future<ConfirmationModel> confirmarSalidaArea(int idSolicitud) async {
    AppLogger.info(_modulo, 'Confirmando salida área: $idSolicitud');

    final respuesta = await _apiClient.post(
      '/visitas/$idSolicitud/confirmar-salida',
    );

    return ConfirmationModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Obtener visitas activas del anfitrión
  Future<List<ConfirmationModel>> obtenerVisitasActivas() async {
    AppLogger.info(_modulo, 'Obteniendo visitas activas');

    final respuesta = await _apiClient.get('/visitas/activas');

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((v) => ConfirmationModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }
}