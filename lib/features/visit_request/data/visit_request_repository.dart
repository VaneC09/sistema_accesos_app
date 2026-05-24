// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_repository.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Repositorio de solicitudes de visita — RF-013, RF-014, RF-015
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/errors/app_logger.dart';
import 'visit_request_datasource.dart';
import 'visit_request_model.dart';

class VisitRequestRepository {
  final VisitRequestDatasource _datasource;
  static const String _modulo = 'VISIT_REQUEST_REPOSITORY';

  VisitRequestRepository({VisitRequestDatasource? datasource})
      : _datasource = datasource ?? VisitRequestDatasource();

  // Crear solicitud
  Future<VisitRequestModel> crearSolicitud(
      VisitRequestModel solicitud,
      ) async {
    try {
      return await _datasource.crearSolicitud(solicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al crear solicitud: $e');
      throw const ServerException(
        mensaje: 'No fue posible crear la solicitud. Intente nuevamente',
      );
    }
  }

  // Obtener mis solicitudes
  Future<List<VisitRequestModel>> obtenerMisSolicitudes({
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      return await _datasource.obtenerMisSolicitudes(
        estado: estado,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener solicitudes: $e');
      throw const ServerException(
        mensaje: 'No fue posible obtener las solicitudes. Intente nuevamente',
      );
    }
  }

  // Obtener detalle
  Future<VisitRequestModel> obtenerDetalle(int idSolicitud) async {
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

  // Cancelar solicitud
  Future<void> cancelarSolicitud(int idSolicitud) async {
    try {
      await _datasource.cancelarSolicitud(idSolicitud);
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al cancelar solicitud: $e');
      throw const ServerException(
        mensaje: 'No fue posible cancelar la solicitud. Intente nuevamente',
      );
    }
  }

  // Obtener tipos de visita
  Future<List<CatalogoModel>> obtenerTiposVisita() async {
    try {
      return await _datasource.obtenerTiposVisita();
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener tipos de visita: $e');
      throw const ServerException(
        mensaje: 'No fue posible cargar los datos. Intente nuevamente',
      );
    }
  }

  // Obtener departamentos
  Future<List<CatalogoModel>> obtenerDepartamentos() async {
    try {
      return await _datasource.obtenerDepartamentos();
    } on AppException {
      rethrow;
    } catch (e) {
      AppLogger.error(_modulo, 'Error al obtener departamentos: $e');
      throw const ServerException(
        mensaje: 'No fue posible cargar los datos. Intente nuevamente',
      );
    }
  }

  // Enviar QR
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

  // Reenviar QR
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

  // Extender QR
  Future<void> extenderQr(int idSolicitud) async {
    try {
      await _datasource.extenderQr(idSolicitud);
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