// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : notification_model.dart
// Módulo    : features/notifications/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.1.0
// =============================================================================

enum TipoNotificacion {
  solicitudAutorizada,
  solicitudRechazada,
  solicitudCancelada,
  visitanteIngreso,
  visitanteSalida,
  visitanteLlegadaTarde,
  permanenciaExcedida,
  qrExtendido,
  qrExpiradoTolerancia,
  solicitudExtension,
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
  final String? estadoSolicitud;

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
    this.estadoSolicitud,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final tipoTexto    = json['tipo']?.toString()    ?? '';
    final mensajeTexto = json['mensaje']?.toString() ?? '';

    return NotificationModel(
      id: json['id_notificaciones']?.toString() ??
          json['id_notificacion']?.toString()   ??
          json['id']?.toString()                ??
          '',
      tipo:   _parseTipo(tipoTexto),
      titulo: json['titulo']?.toString() ?? _generarTitulo(tipoTexto),
      mensaje: mensajeTexto,
      fecha: DateTime.tryParse(
        json['fecha_creado']?.toString()   ??
            json['fecha_creacion']?.toString() ??
            json['created_at']?.toString()     ??
            json['fecha']?.toString()          ??
            '',
      ) ?? DateTime.now(),
      leida:          _toBool(json['leida']),
      idSolicitud:    _toNullableInt(json['id_solicitud']),
      folio:          json['folio']?.toString(),
      nombreVisitante:json['nombre_visitante']?.toString(),
      estadoSolicitud: _parseEstadoSolicitud(json),
    );
  }

  static String? _parseEstadoSolicitud(Map<String, dynamic> json) {
    final directo = json['estado_solicitud']?.toString().trim();
    if (directo != null && directo.isNotEmpty) return directo;

    final estado = json['estado'];
    if (estado is Map) {
      final nombre = estado['nombre']?.toString().trim();
      if (nombre != null && nombre.isNotEmpty) return nombre;
    }

    final plano = json['estado_nombre']?.toString().trim();
    if (plano != null && plano.isNotEmpty) return plano;

    return null;
  }

  static TipoNotificacion _parseTipo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
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

      case 'visitante_salida':
        return TipoNotificacion.visitanteSalida;

      case 'visitante_llegada_tarde':
        return TipoNotificacion.visitanteLlegadaTarde;

      case 'permanencia_excedida':
        return TipoNotificacion.permanenciaExcedida;

      case 'qr_extendido':
        return TipoNotificacion.qrExtendido;

      case 'qr_expirado_tolerancia':
        return TipoNotificacion.qrExpiradoTolerancia;

      case 'solicitud_extension':
        return TipoNotificacion.solicitudExtension;

      default:
        return TipoNotificacion.nuevaSolicitudPendiente;
    }
  }

  static String _generarTitulo(String tipo) {
    switch (tipo.toLowerCase().trim()) {
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
        return 'Visitante en camino';

      case 'visitante_salida':
        return 'Visitante salió del campus';

      case 'visitante_llegada_tarde':
        return 'Llegada fuera de horario';

      case 'permanencia_excedida':
        return 'Permanencia excedida';

      case 'qr_extendido':
        return 'Tiempo de acceso extendido';

      case 'qr_expirado_tolerancia':
        return 'Visitante llegó fuera de horario';

      case 'solicitud_extension':
        return 'Solicitud de tiempo extra';

      default:
        return 'Nueva notificación';
    }
  }

  // ── Helpers de icono y color para usar en la UI ───────────────────────────

  /// Icono representativo según el tipo de notificación
  String get iconoNombre {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
        return 'check_circle';
      case TipoNotificacion.solicitudRechazada:
        return 'cancel';
      case TipoNotificacion.solicitudCancelada:
        return 'remove_circle';
      case TipoNotificacion.visitanteIngreso:
        return 'login';
      case TipoNotificacion.visitanteSalida:
        return 'logout';
      case TipoNotificacion.visitanteLlegadaTarde:
        return 'schedule';
      case TipoNotificacion.permanenciaExcedida:
        return 'timer_off';
      case TipoNotificacion.qrExtendido:
        return 'more_time';
      case TipoNotificacion.qrExpiradoTolerancia:
        return 'warning_amber';
      case TipoNotificacion.solicitudExtension:
        return 'timer';
      case TipoNotificacion.nuevaSolicitudPendiente:
        return 'notifications';
    }
  }

  /// Estado de solicitud inferido del tipo cuando el API no lo envía.
  String get estadoInferido {
    switch (tipo) {
      case TipoNotificacion.solicitudAutorizada:
      case TipoNotificacion.visitanteIngreso:
      case TipoNotificacion.visitanteSalida:
      case TipoNotificacion.visitanteLlegadaTarde:
      case TipoNotificacion.permanenciaExcedida:
      case TipoNotificacion.qrExtendido:
        return 'Autorizada';
      case TipoNotificacion.solicitudRechazada:
        return 'Rechazada';
      case TipoNotificacion.solicitudCancelada:
        return 'Cancelada';
      case TipoNotificacion.nuevaSolicitudPendiente:
      case TipoNotificacion.solicitudExtension:
      case TipoNotificacion.qrExpiradoTolerancia:
        return 'Pendiente';
    }
  }

  /// Indica si requiere acción del usuario (navegar a detalle de solicitud)
  bool get requiereAccion {
    return tipo == TipoNotificacion.qrExpiradoTolerancia ||
        tipo == TipoNotificacion.solicitudExtension   ||
        tipo == TipoNotificacion.solicitudAutorizada;
  }

  static bool _toBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int)  return value == 1;
    final text = value.toString().toLowerCase().trim();
    return text == '1' || text == 'true' || text == 'si' || text == 'sí';
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int)  return value;
    return int.tryParse(value.toString());
  }

  NotificationModel copyWith({bool? leida}) {
    return NotificationModel(
      id:              id,
      tipo:            tipo,
      titulo:          titulo,
      mensaje:         mensaje,
      fecha:           fecha,
      leida:           leida ?? this.leida,
      idSolicitud:     idSolicitud,
      folio:           folio,
      nombreVisitante: nombreVisitante,
      estadoSolicitud: estadoSolicitud,
    );
  }
}