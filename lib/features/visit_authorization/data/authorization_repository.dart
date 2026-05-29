// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_repository.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de autorización — RF-019, RF-020
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import '../../../core/models/paginated_result.dart';
import 'authorization_datasource.dart';
import 'authorization_model.dart';

class AuthorizationRepository {
  final AuthorizationDatasource _datasource;
  static const String _modulo = 'AUTHORIZATION_REPOSITORY';

  AuthorizationRepository({AuthorizationDatasource? datasource})
      : _datasource = datasource ?? AuthorizationDatasource();

  Future<PaginatedResult<AuthorizationModel>> obtenerPendientes({
    String? estado,
    int pagina = 1,
  }) async {
    try {
      return await _datasource.obtenerPendientes(
        estado: estado,
        pagina: pagina,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener pendientes: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener las solicitudes. Intente nuevamente',
      );
    }
  }

  Future<AuthorizationModel> obtenerDetalle(int idSolicitud) async {
    try {
      return await _datasource.obtenerDetalle(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener detalle: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener el detalle. Intente nuevamente',
      );
    }
  }

  Future<void> autorizar(int idSolicitud) async {
    try {
      await _datasource.autorizar(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al autorizar: $e');
      throw const ServerException(
        mensaje: 'No fue posible autorizar la solicitud. Intente nuevamente',
      );
    }
  }

  Future<void> rechazar(int idSolicitud, String motivo) async {
    try {
      await _datasource.rechazar(idSolicitud, motivo);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al rechazar: $e');
      throw const ServerException(
        mensaje: 'No fue posible rechazar la solicitud. Intente nuevamente',
      );
    }
  }
}