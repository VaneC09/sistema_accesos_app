// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_model.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelo de notificaciones — RF-023, RF-019
// =============================================================================

enum TipoNotificacion {
  solicitudAutorizada,
  solicitudRechazada,
  solicitudCancelada,
  visitanteIngreso,
  visitanteLlegadaTarde,
  permanenciaExcedida,
  qrExtendido,
  nuevaSolicitudPendiente,
}

class NotificationModel {
  final String id;
  final TipoNotificacion tipo;
  final String titulo;
  final String mensaje;
  final DateTime fecha;
  final bool leida;
  final int? idSolicitud;
  final String? folio;
  final String? nombreVisitante;

  const NotificationModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.fecha,
    this.leida = false,
    this.idSolicitud,
    this.folio,
    this.nombreVisitante,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      tipo: _parseTipo(json['tipo'] as String? ?? ''),
      titulo: json['titulo'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? '',
      fecha: DateTime.parse(
        json['fecha'] as String? ?? DateTime.now().toIso8601String(),
      ),
      leida: json['leida'] as bool? ?? false,
      idSolicitud: json['id_solicitud'] as int?,
      folio: json['folio'] as String?,
      nombreVisitante: json['nombre_visitante'] as String?,
    );
  }

  static TipoNotificacion _parseTipo(String tipo) {
    switch (tipo) {
      case 'solicitud_autorizada':
        return TipoNotificacion.solicitudAutorizada;
      case 'solicitud_rechazada':
        return TipoNotificacion.solicitudRechazada;
      case 'solicitud_cancelada':
        return TipoNotificacion.solicitudCancelada;
      case 'visitante_ingreso':
        return TipoNotificacion.visitanteIngreso;
      case 'visitante_llegada_tarde':
        return TipoNotificacion.visitanteLlegadaTarde;
      case 'permanencia_excedida':
        return TipoNotificacion.permanenciaExcedida;
      case 'qr_extendido':
        return TipoNotificacion.qrExtendido;
      default:
        return TipoNotificacion.nuevaSolicitudPendiente;
    }
  }

  NotificationModel copyWith({bool? leida}) {
    return NotificationModel(
      id: id,
      tipo: tipo,
      titulo: titulo,
      mensaje: mensaje,
      fecha: fecha,
      leida: leida ?? this.leida,
      idSolicitud: idSolicitud,
      folio: folio,
      nombreVisitante: nombreVisitante,
    );
  }
}