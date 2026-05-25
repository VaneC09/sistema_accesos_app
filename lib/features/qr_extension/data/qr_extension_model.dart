// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_extension_model.dart
// Módulo    : features/qr_extension/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelo de extensión de QR — RF-018, RF-038
// =============================================================================

class QrExtensionModel {
  final int idSolicitud;
  final String folio;
  final DateTime nuevaVigencia;
  final int minutosExtendidos;
  final DateTime fechaExtension;

  const QrExtensionModel({
    required this.idSolicitud,
    required this.folio,
    required this.nuevaVigencia,
    required this.minutosExtendidos,
    required this.fechaExtension,
  });

  factory QrExtensionModel.fromJson(Map<String, dynamic> json) {
    return QrExtensionModel(
      idSolicitud: json['id_solicitud'] as int? ?? 0,
      folio: json['folio'] as String? ?? '',
      nuevaVigencia: DateTime.parse(
        json['nueva_vigencia'] as String? ??
            DateTime.now().toIso8601String(),
      ),
      minutosExtendidos: json['minutos_extendidos'] as int? ?? 15,
      fechaExtension: DateTime.parse(
        json['fecha_extension'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }
}