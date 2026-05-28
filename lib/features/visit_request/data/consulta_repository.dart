// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_repository.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.0.0
// Descripción: Repositorio para visita espontánea de consulta — RF-014
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'consulta_datasource.dart';
import 'consulta_model.dart';

class ConsultaRepository {
  final ConsultaDatasource _datasource;
  static const String _modulo = 'CONSULTA_REPOSITORY';

  ConsultaRepository({ConsultaDatasource? datasource})
      : _datasource = datasource ?? ConsultaDatasource();

  Future<ConsultaResponseModel> registrarConsulta(
      ConsultaRequestModel consulta,
      ) async {
    try {
      return await _datasource.registrarConsulta(consulta);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al registrar consulta: $e');
      throw const ServerException(
        mensaje:
        'No fue posible registrar la visita de consulta. Intente nuevamente',
      );
    }
  }
}