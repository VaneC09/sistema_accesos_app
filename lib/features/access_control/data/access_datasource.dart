// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_datasource.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos de control de acceso — RF-022, RF-025
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'access_model.dart';

class AccessDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'ACCESS_DATASOURCE';

  AccessDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  // Escanear QR — entrada o salida automática
  Future<QrScanResultModel> escanearQr({
    required String codigoQr,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Escaneando QR');

    final respuesta = await _apiClient.post(
      '/acceso/escanear',
      datos: {
        'codigo_qr': codigoQr,
        'telefono': telefono,
        'area': area,
      },
    );

    AppLogger.info(_modulo, 'QR escaneado correctamente');
    return QrScanResultModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Registro manual con código numérico — RF-022
  Future<QrScanResultModel> registroManual({
    required String codigoNumerico,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Registro manual código: $codigoNumerico');

    final respuesta = await _apiClient.post(
      '/acceso/manual',
      datos: {
        'codigo_numerico': codigoNumerico,
        'telefono': telefono,
        'area': area,
      },
    );

    AppLogger.info(_modulo, 'Registro manual exitoso');
    return QrScanResultModel.fromJson(
      respuesta.data as Map<String, dynamic>,
    );
  }

  // Obtener visitas del día — RF-025
  Future<List<VisitaHoyModel>> obtenerVisitasHoy({
    required String telefono,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo visitas del día');

    final respuesta = await _apiClient.get(
      '/visitas/hoy',
      parametros: {'telefono': telefono},
    );

    final lista = respuesta.data as List<dynamic>? ?? [];
    return lista
        .map((v) => VisitaHoyModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }
}