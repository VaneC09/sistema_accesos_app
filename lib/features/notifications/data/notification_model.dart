// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_model.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelo de notificaciones — RF-023
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
    final tipoTexto = json['tipo']?.toString() ?? '';
    final mensajeTexto = json['mensaje']?.toString() ?? '';

    return NotificationModel(
      id: json['id_notificaciones']?.toString() ??
          json['id_notificacion']?.toString() ??
          json['id']?.toString() ??
          '',
      tipo: _parseTipo(tipoTexto),
      titulo: json['titulo']?.toString() ?? _generarTitulo(tipoTexto),
      mensaje: mensajeTexto,
      fecha: DateTime.tryParse(
        json['fecha_creado']?.toString() ??
            json['fecha_creacion']?.toString() ??
            json['created_at']?.toString() ??
            json['fecha']?.toString() ??
            '',
      ) ??
          DateTime.now(),
      leida: _toBool(json['leida']),
      idSolicitud: _toNullableInt(json['id_solicitud']),
      folio: json['folio']?.toString(),
      nombreVisitante: json['nombre_visitante']?.toString(),
    );
  }

  static TipoNotificacion _parseTipo(String tipo) {
    final t = tipo.toLowerCase().trim();

    switch (t) {
      case 'autorizada':
      case 'solicitud_autorizada':
        return TipoNotificacion.solicitudAutorizada;

      case 'rechazada':
      case 'rechazado':
      case 'solicitud_rechazada':
        return TipoNotificacion.solicitudRechazada;

      case 'cancelada':
      case 'cancelado':
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

  static String _generarTitulo(String tipo) {
    final t = tipo.toLowerCase().trim();

    switch (t) {
      case 'autorizada':
      case 'solicitud_autorizada':
        return 'Solicitud autorizada';

      case 'rechazada':
      case 'rechazado':
      case 'solicitud_rechazada':
        return 'Solicitud rechazada';

      case 'cancelada':
      case 'cancelado':
      case 'solicitud_cancelada':
        return 'Solicitud cancelada';

      case 'visitante_ingreso':
        return 'Visitante registrado';

      case 'visitante_llegada_tarde':
        return 'Llegada fuera de horario';

      case 'permanencia_excedida':
        return 'Permanencia excedida';

      case 'qr_extendido':
        return 'QR extendido';

      default:
        return 'Nueva notificación';
    }
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;

    final text = value.toString().toLowerCase().trim();

    return text == '1' || text == 'true' || text == 'si' || text == 'sí';
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  NotificationModel copyWith({
    bool? leida,
  }) {
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