// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : consulta_model.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.1.0
// Descripción: Modelo para visita espontánea de consulta — RF-014, RF-049
//              Ahora separa nombre(s) y apellidos del visitante.
// =============================================================================

class ConsultaRequestModel {
  final String nombreVisitante;
  final String apellidosVisitante;
  final String correoVisitante;
  final String lugarDestino;

  const ConsultaRequestModel({
    required this.nombreVisitante,
    required this.apellidosVisitante,
    required this.correoVisitante,
    required this.lugarDestino,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_visitante': nombreVisitante,
      'apellidos_visitante': apellidosVisitante,
      'correo_visitante': correoVisitante,
      'lugar_destino': lugarDestino,
    };
  }
}

class ConsultaResponseModel {
  final String folio;
  final String codigoQr;
  final String nombreVisitante;
  final String apellidosVisitante;
  final String nombreCompleto;
  final String correoVisitante;
  final String lugarDestino;
  final bool correoEnviado;
  final String mensaje;

  const ConsultaResponseModel({
    required this.folio,
    required this.codigoQr,
    required this.nombreVisitante,
    required this.apellidosVisitante,
    required this.nombreCompleto,
    required this.correoVisitante,
    required this.lugarDestino,
    required this.correoEnviado,
    required this.mensaje,
  });

  factory ConsultaResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final nombre = data['nombre_visitante']?.toString() ?? '';
    final apellidos = data['apellidos_visitante']?.toString() ?? '';

    return ConsultaResponseModel(
      folio: data['folio']?.toString() ?? '',
      codigoQr: data['codigo_qr']?.toString() ??
          data['codigo_numerico']?.toString() ??
          '',
      nombreVisitante: nombre,
      apellidosVisitante: apellidos,
      nombreCompleto: data['nombre_completo']?.toString() ??
          '$nombre $apellidos'.trim(),
      correoVisitante: data['correo_visitante']?.toString() ?? '',
      lugarDestino: data['lugar_destino']?.toString() ??
          data['lugar_encuentro']?.toString() ??
          '',
      correoEnviado: data['correo_enviado'] == true,
      mensaje: json['message']?.toString() ??
          data['message']?.toString() ??
          'Visita de consulta registrada correctamente.',
    );
  }
}