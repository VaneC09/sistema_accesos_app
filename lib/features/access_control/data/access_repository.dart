// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_repository.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-27
// Versión   : 1.2.1
// Descripción: Repositorio de control de acceso funcional y limpio — RF-022, RF-025
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

  // ── Métodos de Inspección Inicial ─────────────────────────────────────────

  /// Escanear QR para consultar datos del visitante
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

  /// Registro manual usando código numérico
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

  /// Obtener visitas del día para el Home del vigilante
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

  // ── Métodos de Confirmación de Flujo (Entrada / Salida) ────────────────────

  /// Registra la Entrada definitiva usando los parámetros del vigilante activo
  Future<void> registrarEntrada({
    required int idQr,
    required String telefono,
    required String area,
  }) async {
    try {
      await _datasource.registrarEntrada(
        idQr: idQr,
        telefono: telefono,
        area: area,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al registrar entrada: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar la entrada',
      );
    }
  }

  /// Registra la Salida definitiva usando los parámetros del vigilante activo
  Future<void> registrarSalida({
    required int idQr,
    required String telefono,
    required String area,
  }) async {
    try {
      await _datasource.registrarSalida(
        idQr: idQr,
        telefono: telefono,
        area: area,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al registrar salida: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar la salida',
      );
    }
  }
}