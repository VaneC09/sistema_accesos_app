// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_datasource.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos mock de control de acceso — RF-022, RF-025
// =============================================================================

import '../../../core/errors/app_logger.dart';
import 'access_model.dart';

class AccessDatasource {
  static const String _modulo = 'ACCESS_DATASOURCE';

  Future<QrScanResultModel> escanearQr({
    required String codigoQr,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Escaneando QR mock');
    await Future.delayed(const Duration(milliseconds: 500));
    return QrScanResultModel(
      folio: 'VIS-001',
      nombreVisitante: 'Juan Pérez',
      lugarDestino: 'Edificio T - Oficina 301',
      estado: 'Autorizada',
      tipoAcceso: 'entrada',
      accesoConcedido: true,
      llegaTarde: false,
      llegaAnticiapdo: false,
    );
  }

  Future<QrScanResultModel> registroManual({
    required String codigoNumerico,
    required String telefono,
    required String area,
  }) async {
    AppLogger.info(_modulo, 'Registro manual mock: $codigoNumerico');
    await Future.delayed(const Duration(milliseconds: 500));
    return QrScanResultModel(
      folio: 'VIS-002',
      nombreVisitante: 'María López',
      lugarDestino: 'Recursos Materiales',
      estado: 'Autorizada',
      tipoAcceso: 'entrada',
      accesoConcedido: true,
      llegaTarde: false,
      llegaAnticiapdo: false,
    );
  }

  Future<List<VisitaHoyModel>> obtenerVisitasHoy({
    required String telefono,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo visitas del día mock');
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      VisitaHoyModel(
        folio: 'VIS-001',
        nombreVisitante: 'Juan Pérez',
        lugarDestino: 'Edificio T - Oficina 301',
        tipoVisita: 'Personal',
        horaVisita: DateTime.now().add(const Duration(hours: 1)),
        estado: 'Autorizada',
        entradaRegistrada: false,
        salidaRegistrada: false,
      ),
      VisitaHoyModel(
        folio: 'VIS-002',
        nombreVisitante: 'María López',
        lugarDestino: 'Recursos Materiales',
        tipoVisita: 'Proveedor',
        horaVisita: DateTime.now().add(const Duration(hours: 2)),
        estado: 'Autorizada',
        entradaRegistrada: true,
        salidaRegistrada: false,
      ),
      VisitaHoyModel(
        folio: 'VIS-003',
        nombreVisitante: 'Carlos Sánchez',
        lugarDestino: 'Dirección',
        tipoVisita: 'Consulta',
        horaVisita: DateTime.now().subtract(const Duration(hours: 1)),
        estado: 'Autorizada',
        entradaRegistrada: true,
        salidaRegistrada: true,
      ),
    ];
  }
}