// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_datasource.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// =============================================================================

import '../../../core/errors/app_logger.dart';
import 'visit_request_model.dart';

class VisitRequestDatasource {
  static const String _modulo = 'VISIT_REQUEST_DATASOURCE';

  Future<VisitRequestModel> crearSolicitud(VisitRequestModel solicitud) async {
    AppLogger.info(_modulo, 'Creando solicitud mock');
    await Future.delayed(const Duration(milliseconds: 500));
    return VisitRequestModel(
      idSolicitud: 1,
      tipoVisita: solicitud.tipoVisita,
      esGrupal: solicitud.esGrupal,
      visitantes: solicitud.visitantes,
      lugarDestino: solicitud.lugarDestino,
      fechaVisita: solicitud.fechaVisita,
      motivoVisita: solicitud.motivoVisita,
      toleranciaAntesMinutos: solicitud.toleranciaAntesMinutos,
      toleranciaDespuesMinutos: solicitud.toleranciaDespuesMinutos,
      estado: 'Pendiente',
      folio: 'VIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
  }

  Future<List<VisitRequestModel>> obtenerMisSolicitudes({
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    AppLogger.info(_modulo, 'Obteniendo solicitudes mock');
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      VisitRequestModel(
        idSolicitud: 1,
        tipoVisita: 'Personal',
        esGrupal: false,
        visitantes: [
          VisitanteModel(nombre: 'Juan Pérez', correo: 'juan@gmail.com'),
        ],
        lugarDestino: 'Edificio T',
        fechaVisita: DateTime.now().add(const Duration(days: 1)),
        motivoVisita: 'Reunión de trabajo',
        toleranciaAntesMinutos: 15,
        toleranciaDespuesMinutos: 15,
        estado: 'Pendiente',
        folio: 'VIS-001',
      ),
      VisitRequestModel(
        idSolicitud: 2,
        tipoVisita: 'Proveedor',
        esGrupal: false,
        visitantes: [
          VisitanteModel(nombre: 'María López', correo: 'maria@empresa.com'),
        ],
        lugarDestino: 'Recursos Materiales',
        fechaVisita: DateTime.now().add(const Duration(days: 2)),
        motivoVisita: 'Entrega de material',
        toleranciaAntesMinutos: 15,
        toleranciaDespuesMinutos: 15,
        estado: 'Autorizada',
        folio: 'VIS-002',
      ),
    ];
  }

  Future<VisitRequestModel> obtenerDetalle(int idSolicitud) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return VisitRequestModel(
      idSolicitud: idSolicitud,
      tipoVisita: 'Personal',
      esGrupal: false,
      visitantes: [
        VisitanteModel(nombre: 'Juan Pérez', correo: 'juan@gmail.com'),
      ],
      lugarDestino: 'Edificio T',
      fechaVisita: DateTime.now().add(const Duration(days: 1)),
      motivoVisita: 'Reunión de trabajo',
      toleranciaAntesMinutos: 15,
      toleranciaDespuesMinutos: 15,
      estado: 'Pendiente',
      folio: 'VIS-00$idSolicitud',
    );
  }

  Future<void> cancelarSolicitud(int idSolicitud) async {
    AppLogger.info(_modulo, 'Cancelando solicitud mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<List<CatalogoModel>> obtenerTiposVisita() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const CatalogoModel(id: 1, nombre: 'Personal'),
      const CatalogoModel(id: 2, nombre: 'Proveedor'),
      const CatalogoModel(id: 3, nombre: 'Consulta'),
    ];
  }

  Future<List<CatalogoModel>> obtenerDepartamentos() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      const CatalogoModel(id: 1, nombre: 'Sistemas y Computación'),
      const CatalogoModel(id: 2, nombre: 'Recursos Materiales'),
      const CatalogoModel(id: 3, nombre: 'Desarrollo Académico'),
      const CatalogoModel(id: 4, nombre: 'Comunicación y Difusión'),
      const CatalogoModel(id: 5, nombre: 'Alberca'),
    ];
  }

  Future<void> enviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Enviando QR mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> reenviarQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Reenviando QR mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<void> extenderQr(int idSolicitud) async {
    AppLogger.info(_modulo, 'Extendiendo QR mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 300));
  }
}