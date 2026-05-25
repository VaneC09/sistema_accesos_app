// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_generation_datasource.dart
// Módulo    : features/qr_generation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de generación QR — RF-021, RF-032
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'qr_generation_model.dart';

class QrGenerationDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'QR_GENERATION_DATASOURCE';

  QrGenerationDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Obtener QR de una solicitud autorizada
  Future<List<QrGenerationModel>> obtenerQrSolicitud(
      int idSolicitud,
      ) async {
    AppLogger.info(_modulo, 'Obteniendo QR solicitud: $idSolicitud');

    final respuesta = await _apiClient.get(
      '/solicitudes/$idSolicitud/qr',
    );

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((q) => QrGenerationModel.fromJson(q as Map<String, dynamic>))
        .toList();
  }

  // Enviar QR por correo
  Future<void> enviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Enviando QR: $idSolicitud');
    await _apiClient.post('/solicitudes/$idSolicitud/enviar-qr');
    AppLogger.info(_modulo, 'QR enviado: $idSolicitud');
  }

  // Reenviar QR
  Future<void> reenviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Reenviando QR: $idSolicitud');
    await _apiClient.post('/solicitudes/$idSolicitud/reenviar-qr');
    AppLogger.info(_modulo, 'QR reenviado: $idSolicitud');
  }
}