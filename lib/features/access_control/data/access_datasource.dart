// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_datasource.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.1.0
// Descripción: Fuente de datos de control de acceso con persistencia de flujos — RF-022, RF-025
// =============================================================================

import '../../../core/connection/api_client.dart';
import '../../../core/errors/app_logger.dart';
import 'access_model.dart';

class AccessDatasource {
  final ApiClient _apiClient;
  static const String _modulo = 'ACCESS_DATASOURCE';

  AccessDatasource({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instancia;

  /// Escanea un código QR para validar el acceso.
  Future<QrScanResultModel> escanearQr({
    required String codigoQr,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Escaneando QR');
    final respuesta = await _apiClient.post(
      '/vigilante/escanear',
      datos: { 'codigo_qr': codigoQr, 'telefono': telefono, 'area': area },
    );
    AppLogger.info(_modulo, 'Respuesta raw escanear: ${respuesta.data}');
    final body = respuesta.data as Map<String, dynamic>;
    return QrScanResultModel.fromJson(body['data'] as Map<String, dynamic>);
  } // <-- ¡AQUÍ FALTABA ESTA LLAVE DE CIERRE!

  /// Registro manual: Mapea a la misma ruta de escanear utilizando 'codigo_qr'
  Future<QrScanResultModel> registroManual({
    required String codigoNumerico,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Registro manual: $codigoNumerico');
    final respuesta = await _apiClient.post(
      '/vigilante/escanear', // ← Ruta unificada con escanearQr
      datos: {
        'codigo_qr': codigoNumerico, // ← El backend espera 'codigo_qr' para el código numérico
        'telefono': telefono,
        'area': area
      },
    );

    AppLogger.info(_modulo, 'Respuesta raw escanear: ${respuesta.data}');
    final body = respuesta.data as Map<String, dynamic>;
    return QrScanResultModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// Obtiene la lista de visitas programadas para el día de hoy desenvolviendo el campo 'data'.
  Future<List<VisitaHoyModel>> obtenerVisitasHoy({
    required String telefono,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo visitas del dia');
    final respuesta = await _apiClient.get(
      '/vigilante/visitas-hoy',
      // El teléfono no afecta el resultado (Laravel no lo usa),
      // pero lo mandamos por si acaso se loguea en el futuro
      parametros: {'telefono': telefono},
    );

    // Laravel responde { "data": [...] }  ← hay que desenvolver
    final body  = respuesta.data as Map<String, dynamic>;
    final lista = body['data'] as List<dynamic>? ?? [];

    return lista
        .map((v) => VisitaHoyModel.fromJson(v as Map<String, dynamic>))
        .toList();
  }

  /// Envía la confirmación explícita para registrar la entrada de una visita autorizada.
  Future<void> registrarEntrada({
    required int idQr,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Registrando entrada — id_qr: $idQr');
    await _apiClient.post(
      '/vigilante/entrada',
      datos: {
        'id_qr': idQr,
        'telefono': telefono,
        'area': area
      },
    );
  }

  /// Envía la confirmación explícita para registrar la salida de una visita autorizada.
  Future<void> registrarSalida({
    required int idQr,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Registrando salida — id_qr: $idQr');
    await _apiClient.post(
      '/vigilante/salida',
      datos: {
        'id_qr': idQr,
        'telefono': telefono,
        'area': area
      },
    );
  }
}