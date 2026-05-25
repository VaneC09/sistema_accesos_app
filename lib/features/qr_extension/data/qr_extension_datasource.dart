// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_extension_datasource.dart
// Módulo    : features/qr_extension/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de extensión QR — RF-018, RF-038
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'qr_extension_model.dart';

class QrExtensionDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'QR_EXTENSION_DATASOURCE';

  QrExtensionDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Extender vigencia del QR
  Future<QrExtensionModel> extenderQr({
    required int idSolicitud,
    required int minutosExtra,
  }) async {
    AppLogger.info(_modulo, 'Extendiendo QR solicitud: $idSolicitud');

    final respuesta = await _apiClient.post(
      '/solicitudes/$idSolicitud/extender-qr',
      datos: {'minutos_extra': minutosExtra},
    );

    AppLogger.info(_modulo, 'QR extendido exitosamente');
    return QrExtensionModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }
}