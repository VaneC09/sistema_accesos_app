// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_repository.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de control de acceso — RF-022, RF-025
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'access_datasource.dart';
import 'access_model.dart';

class AccessRepository {
  final AccessDatasource _datasource;
  static const String _modulo = 'ACCESS_REPOSITORY';

  AccessRepository({AccessDatasource? datasource})
      : _datasource = datasource ?? AccessDatasource();

  // Escanear QR
  Future<QrScanResultModel> escanearQr({
    required String codigoQr,
    required String telefono,
    required String area,
  }) async {
    try {
      return await _datasource.escanearQr(
        codigoQr: codigoQr,
        telefono: telefono,
        area: area,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al escanear QR: $e');
      throw const ServerException(
        mensaje: 'No fue posible validar el QR. Intente nuevamente',
      );
    }
  }

  // Registro manual
  Future<QrScanResultModel> registroManual({
    required String codigoNumerico,
    required String telefono,
    required String area,
  }) async {
    try {
      return await _datasource.registroManual(
        codigoNumerico: codigoNumerico,
        telefono: telefono,
        area: area,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error en registro manual: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar el acceso. Intente nuevamente',
      );
    }
  }

  // Obtener visitas del día
  Future<List<VisitaHoyModel>> obtenerVisitasHoy({
    required String telefono,
  }) async {
    try {
      return await _datasource.obtenerVisitasHoy(telefono: telefono);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener visitas: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener las visitas. Intente nuevamente',
      );
    }
  }
}