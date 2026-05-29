// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : confirmation_model.dart
// Módulo    : features/visit_confirmation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.1
// Descripción: Modelo de confirmación de visita — RF-026, RF-051, RF-052
// =============================================================================

class ConfirmationModel {
  final int idSolicitud;
  final String folio;
  final String nombreVisitante;
  final String lugarDestino;
  final DateTime? horaLlegadaCampus;
  final DateTime? horaLlegadaArea;
  final DateTime? horaSalidaArea;
  final DateTime? horaSalidaCampus;
  final int? tiempoPermanecinaMinutos;
  final String estado;

  const ConfirmationModel({
    required this.idSolicitud,
    required this.folio,
    required this.nombreVisitante,
    required this.lugarDestino,
    this.horaLlegadaCampus,
    this.horaLlegadaArea,
    this.horaSalidaArea,
    this.horaSalidaCampus,
    this.tiempoPermanecinaMinutos,
    required this.estado,
  });

  factory ConfirmationModel.fromJson(Map<String, dynamic> json) {
    return ConfirmationModel(
      // Campos obligatorios (Non-nullable en el modelo, con fallback seguro)
      idSolicitud: json['id_solicitud'] as int? ?? 0,
      folio: json['folio'] as String? ?? '',
      nombreVisitante: json['nombre_visitante'] as String? ?? '',
      lugarDestino: json['lugar_destino'] as String? ?? '',
      estado: json['estado'] as String? ?? '',

      // Campos opcionales (Fechas - Nullable)
      horaLlegadaCampus: json['hora_llegada_campus'] != null
          ? DateTime.parse(json['hora_llegada_campus'] as String)
          : null,
      horaLlegadaArea: json['hora_llegada_area'] != null
          ? DateTime.parse(json['hora_llegada_area'] as String)
          : null,
      horaSalidaArea: json['hora_salida_area'] != null
          ? DateTime.parse(json['hora_salida_area'] as String)
          : null,
      horaSalidaCampus: json['hora_salida_campus'] != null
          ? DateTime.parse(json['hora_salida_campus'] as String)
          : null,

      // Campo opcional (Entero - Nullable)
      tiempoPermanecinaMinutos: json['tiempo_permanencia_minutos'] as int?,
    );
  }

  // Opcional: Se agrega método toJson por si necesitas enviar este modelo de vuelta al Backend
  Map<String, dynamic> toJson() {
    return {
      'id_solicitud': idSolicitud,
      'folio': folio,
      'nombre_visitante': nombreVisitante,
      'lugar_destino': lugarDestino,
      'hora_llegada_campus': horaLlegadaCampus?.toIso8601String(),
      'hora_llegada_area': horaLlegadaArea?.toIso8601String(),
      'hora_salida_area': horaSalidaArea?.toIso8601String(),
      'hora_salida_campus': horaSalidaCampus?.toIso8601String(),
      'tiempo_permanencia_minutos': tiempoPermanecinaMinutos,
      'estado': estado,
    };
  }
}