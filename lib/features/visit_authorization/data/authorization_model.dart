// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_model.dart
// Módulo    : features/visit_authorization/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelos de autorización de visitas — RF-019, RF-020
// =============================================================================

class AuthorizationModel {
  final int idSolicitud;
  final String folio;
  final String nombreAnfitrion;
  final String correoAnfitrion;
  final String tipoVisita;
  final String motivoVisita;
  final String lugarDestino;
  final DateTime fechaVisita;
  final int toleranciaAntes;
  final int toleranciaDespues;
  final List<VisitanteAuthModel> visitantes;
  final String estado;
  final DateTime fechaCreacion;

  const AuthorizationModel({
    required this.idSolicitud,
    required this.folio,
    required this.nombreAnfitrion,
    required this.correoAnfitrion,
    required this.tipoVisita,
    required this.motivoVisita,
    required this.lugarDestino,
    required this.fechaVisita,
    required this.toleranciaAntes,
    required this.toleranciaDespues,
    required this.visitantes,
    required this.estado,
    required this.fechaCreacion,
  });

  factory AuthorizationModel.fromJson(Map<String, dynamic> json) {
    return AuthorizationModel(
      idSolicitud: json['id_solicitud'] as int? ?? 0,
      folio: json['folio'] as String? ?? '',
      nombreAnfitrion: json['nombre_anfitrion'] as String? ?? '',
      correoAnfitrion: json['correo_anfitrion'] as String? ?? '',
      tipoVisita: json['tipo_visita'] as String? ?? '',
      motivoVisita: json['motivo_visita'] as String? ?? '',
      lugarDestino: json['lugar_encuentro'] as String? ?? '',
      fechaVisita: DateTime.parse(
        json['fecha_inicio'] as String? ?? DateTime.now().toIso8601String(),
      ),
      toleranciaAntes: json['tolerancia_antes'] as int? ?? 15,
      toleranciaDespues: json['tolerancia_despues'] as int? ?? 15,
      visitantes: (json['visitantes'] as List<dynamic>? ?? [])
          .map((v) => VisitanteAuthModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      estado: json['estado'] as String? ?? 'Pendiente',
      fechaCreacion: DateTime.parse(
        json['fecha_creacion'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class VisitanteAuthModel {
  final String nombre;
  final String correo;

  const VisitanteAuthModel({
    required this.nombre,
    required this.correo,
  });

  factory VisitanteAuthModel.fromJson(Map<String, dynamic> json) {
    return VisitanteAuthModel(
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
    );
  }
}