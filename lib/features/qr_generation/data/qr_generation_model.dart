// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_generation_model.dart
// Módulo    : features/qr_generation/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelo de generación de QR — RF-021, RF-032, RF-033
// =============================================================================

class QrGenerationModel {
  final int idSolicitud;
  final String folio;
  final String codigoQr;
  final String codigoNumerico;
  final String nombreVisitante;
  final String correoVisitante;
  final String nombreAnfitrion;
  final String lugarDestino;
  final DateTime fechaVisita;
  final DateTime vigenciaInicio;
  final DateTime vigenciaFin;
  final String estado;
  final int reenvios;
  final int maxReenvios;

  const QrGenerationModel({
    required this.idSolicitud,
    required this.folio,
    required this.codigoQr,
    required this.codigoNumerico,
    required this.nombreVisitante,
    required this.correoVisitante,
    required this.nombreAnfitrion,
    required this.lugarDestino,
    required this.fechaVisita,
    required this.vigenciaInicio,
    required this.vigenciaFin,
    required this.estado,
    required this.reenvios,
    required this.maxReenvios,
  });

  bool get puedeReenviar => reenvios < maxReenvios;
  bool get estaVigente => DateTime.now().isBefore(vigenciaFin);

  factory QrGenerationModel.fromJson(Map<String, dynamic> json) {
    return QrGenerationModel(
      idSolicitud: json['id_solicitud'] as int? ?? 0,
      folio: json['folio'] as String? ?? '',
      codigoQr: json['codigo_qr'] as String? ?? '',
      codigoNumerico: json['codigo_numerico'] as String? ?? '00000000',
      nombreVisitante: json['nombre_visitante'] as String? ?? '',
      correoVisitante: json['correo_visitante'] as String? ?? '',
      nombreAnfitrion: json['nombre_anfitrion'] as String? ?? '',
      lugarDestino: json['lugar_destino'] as String? ?? '',
      fechaVisita: DateTime.parse(
        json['fecha_visita'] as String? ?? DateTime.now().toIso8601String(),
      ),
      vigenciaInicio: DateTime.parse(
        json['vigencia_inicio'] as String? ?? DateTime.now().toIso8601String(),
      ),
      vigenciaFin: DateTime.parse(
        json['vigencia_fin'] as String? ?? DateTime.now().toIso8601String(),
      ),
      estado: json['estado'] as String? ?? '',
      reenvios: json['reenvios'] as int? ?? 0,
      maxReenvios: json['max_reenvios'] as int? ?? 3,
    );
  }
}