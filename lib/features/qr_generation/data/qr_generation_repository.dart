// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_generation_repository.dart
// Módulo    : features/qr_generation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de generación QR — RF-021, RF-032
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'qr_generation_datasource.dart';
import 'qr_generation_model.dart';

class QrGenerationRepository {
  final QrGenerationDatasource _datasource;
  static const String _modulo = 'QR_GENERATION_REPOSITORY';

  QrGenerationRepository({QrGenerationDatasource? datasource})
      : _datasource = datasource ?? QrGenerationDatasource();

  Future<List<QrGenerationModel>> obtenerQrSolicitud(
      int idSolicitud,
      ) async {
    try {
      return await _datasource.obtenerQrSolicitud(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener QR: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener el QR. Intente nuevamente',
      );
    }
  }

  Future<void> enviarQr(int idSolicitud) async {
    try {
      await _datasource.enviarQr(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al enviar QR: $e');
      throw const ServerException(
        mensaje: 'No fue posible enviar el pase. Intente más tarde.',
      );
    }
  }

  Future<void> reenviarQr(int idSolicitud) async {
    try {
      await _datasource.reenviarQr(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al reenviar QR: $e');
      throw const ServerException(
        mensaje: 'No fue posible reenviar el pase. Intente más tarde.',
      );
    }
  }
}