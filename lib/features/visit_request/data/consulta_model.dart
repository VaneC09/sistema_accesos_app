// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_model.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.0.0
// Descripción: Modelo para visita espontánea de consulta — RF-014, RF-049
// =============================================================================

class ConsultaRequestModel {
  final String nombreVisitante;
  final String correoVisitante;
  final String lugarDestino;

  const ConsultaRequestModel({
    required this.nombreVisitante,
    required this.correoVisitante,
    required this.lugarDestino,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_visitante': nombreVisitante,
      'correo_visitante': correoVisitante,
      'lugar_destino': lugarDestino,
    };
  }
}

class ConsultaResponseModel {
  final String folio;
  final String codigoQr;
  final String nombreVisitante;
  final String correoVisitante;
  final String lugarDestino;
  final String mensaje;

  const ConsultaResponseModel({
    required this.folio,
    required this.codigoQr,
    required this.nombreVisitante,
    required this.correoVisitante,
    required this.lugarDestino,
    required this.mensaje,
  });

  factory ConsultaResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return ConsultaResponseModel(
      folio: data['folio']?.toString() ?? '',
      codigoQr: data['codigo_qr']?.toString() ??
          data['codigo_numerico']?.toString() ??
          '',
      nombreVisitante: data['nombre_visitante']?.toString() ?? '',
      correoVisitante: data['correo_visitante']?.toString() ?? '',
      lugarDestino: data['lugar_destino']?.toString() ??
          data['lugar_encuentro']?.toString() ??
          '',
      mensaje: json['message']?.toString() ??
          data['message']?.toString() ??
          'Visita de consulta registrada correctamente.',
    );
  }
}