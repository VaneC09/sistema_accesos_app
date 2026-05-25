// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : confirmation_repository.dart
// Módulo    : features/visit_confirmation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de confirmación — RF-026, RF-051, RF-052
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'confirmation_datasource.dart';
import 'confirmation_model.dart';

class ConfirmationRepository {
  final ConfirmationDatasource _datasource;
  static const String _modulo = 'CONFIRMATION_REPOSITORY';

  ConfirmationRepository({ConfirmationDatasource? datasource})
      : _datasource = datasource ?? ConfirmationDatasource();

  Future<ConfirmationModel> confirmarLlegadaArea(int idSolicitud) async {
    try {
      return await _datasource.confirmarLlegadaArea(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al confirmar llegada: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar llegada',
      );
    }
  }

  Future<ConfirmationModel> confirmarSalidaArea(int idSolicitud) async {
    try {
      return await _datasource.confirmarSalidaArea(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al confirmar salida: $e');
      throw const ServerException(
        mensaje: 'No fue posible registrar salida',
      );
    }
  }

  Future<List<ConfirmationModel>> obtenerVisitasActivas() async {
    try {
      return await _datasource.obtenerVisitasActivas();
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener visitas activas: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener las visitas activas',
      );
    }
  }
}