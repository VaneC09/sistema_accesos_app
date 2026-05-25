// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_extension_repository.dart
// Módulo    : features/qr_extension/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de extensión QR — RF-018, RF-038
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'qr_extension_datasource.dart';
import 'qr_extension_model.dart';

class QrExtensionRepository {
  final QrExtensionDatasource _datasource;
  static const String _modulo = 'QR_EXTENSION_REPOSITORY';

  QrExtensionRepository({QrExtensionDatasource? datasource})
      : _datasource = datasource ?? QrExtensionDatasource();

  Future<QrExtensionModel> extenderQr({
    required int idSolicitud,
    required int minutosExtra,
  }) async {
    try {
      return await _datasource.extenderQr(
        idSolicitud: idSolicitud,
        minutosExtra: minutosExtra,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al extender QR: $e');
      throw const ServerException(
        mensaje: 'No fue posible extender la vigencia del QR.',
      );
    }
  }
}