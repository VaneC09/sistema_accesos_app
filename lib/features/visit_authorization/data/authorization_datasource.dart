// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_datasource.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Fuente de datos mock de autorización — RF-019, RF-020
// =============================================================================

import '../../../core/errors/app_logger.dart';
import 'authorization_model.dart';

class AuthorizationDatasource {
  static const String _modulo = 'AUTHORIZATION_DATASOURCE';

  Future<List<AuthorizationModel>> obtenerPendientes() async {
    AppLogger.info(_modulo, 'Obteniendo pendientes mock');
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AuthorizationModel(
        idSolicitud: 1,
        folio: 'VIS-001',
        nombreAnfitrion: 'Juan Martínez',
        correoAnfitrion: 'empleado@toluca.tecnm.mx',
        tipoVisita: 'Personal',
        motivoVisita: 'Reunión de trabajo',
        lugarDestino: 'Edificio T - Oficina 301',
        fechaVisita: DateTime.now().add(const Duration(days: 1)),
        toleranciaAntes: 15,
        toleranciaDespues: 15,
        visitantes: [
          const VisitanteAuthModel(
            nombre: 'Pedro Ramírez',
            correo: 'pedro@gmail.com',
          ),
        ],
        estado: 'Pendiente',
        fechaCreacion: DateTime.now(),
      ),
      AuthorizationModel(
        idSolicitud: 2,
        folio: 'VIS-002',
        nombreAnfitrion: 'Ana López',
        correoAnfitrion: 'empleado2@toluca.tecnm.mx',
        tipoVisita: 'Proveedor',
        motivoVisita: 'Entrega de equipo de cómputo',
        lugarDestino: 'Recursos Materiales',
        fechaVisita: DateTime.now().add(const Duration(days: 2)),
        toleranciaAntes: 30,
        toleranciaDespues: 30,
        visitantes: [
          const VisitanteAuthModel(
            nombre: 'Carlos Sánchez',
            correo: 'carlos@empresa.com',
          ),
          const VisitanteAuthModel(
            nombre: 'Luis Torres',
            correo: 'luis@empresa.com',
          ),
        ],
        estado: 'Pendiente',
        fechaCreacion: DateTime.now(),
      ),
    ];
  }

  Future<AuthorizationModel> obtenerDetalle(int idSolicitud) async {
    AppLogger.info(_modulo, 'Obteniendo detalle mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 300));
    return AuthorizationModel(
      idSolicitud: idSolicitud,
      folio: 'VIS-00$idSolicitud',
      nombreAnfitrion: 'Juan Martínez',
      correoAnfitrion: 'empleado@toluca.tecnm.mx',
      tipoVisita: 'Personal',
      motivoVisita: 'Reunión de trabajo',
      lugarDestino: 'Edificio T - Oficina 301',
      fechaVisita: DateTime.now().add(const Duration(days: 1)),
      toleranciaAntes: 15,
      toleranciaDespues: 15,
      visitantes: [
        const VisitanteAuthModel(
          nombre: 'Pedro Ramírez',
          correo: 'pedro@gmail.com',
        ),
      ],
      estado: 'Pendiente',
      fechaCreacion: DateTime.now(),
    );
  }

  Future<void> autorizar(int idSolicitud) async {
    AppLogger.info(_modulo, 'Autorizando mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> rechazar(int idSolicitud, String motivo) async {
    AppLogger.info(_modulo, 'Rechazando mock: $idSolicitud');
    await Future.delayed(const Duration(milliseconds: 500));
  }
}