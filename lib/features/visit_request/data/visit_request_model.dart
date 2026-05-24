// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_model.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelos de solicitud de visita — RF-013, RF-014
// =============================================================================

class VisitanteModel {
  final String nombre;
  final String correo;

  const VisitanteModel({
    required this.nombre,
    required this.correo,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) {
    return VisitanteModel(
      nombre: json['nombre'] as String? ?? '',
      correo: json['correo'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
    };
  }
}

class VisitRequestModel {
  final int? idSolicitud;
  final String tipoVisita;
  final bool esGrupal;
  final List<VisitanteModel> visitantes;
  final String lugarDestino;
  final DateTime fechaVisita;
  final String motivoVisita;
  final int toleranciaAntesMinutos;
  final int toleranciaDespuesMinutos;
  final String estado;
  final String? folio;
  final DateTime? fechaCreacion;
  final int? idSolicitante;

  const VisitRequestModel({
    this.idSolicitud,
    required this.tipoVisita,
    required this.esGrupal,
    required this.visitantes,
    required this.lugarDestino,
    required this.fechaVisita,
    required this.motivoVisita,
    required this.toleranciaAntesMinutos,
    required this.toleranciaDespuesMinutos,
    this.estado = 'Pendiente',
    this.folio,
    this.fechaCreacion,
    this.idSolicitante,
  });

  factory VisitRequestModel.fromJson(Map<String, dynamic> json) {
    return VisitRequestModel(
      idSolicitud: json['id_solicitud'] as int?,
      tipoVisita: json['tipo_visita'] as String? ?? '',
      esGrupal: json['es_grupal'] as bool? ?? false,
      visitantes: (json['visitantes'] as List<dynamic>? ?? [])
          .map((v) => VisitanteModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      lugarDestino: json['lugar_encuentro'] as String? ?? '',
      fechaVisita: DateTime.parse(
        json['fecha_inicio'] as String? ?? DateTime.now().toIso8601String(),
      ),
      motivoVisita: json['motivo_visita'] as String? ?? '',
      toleranciaAntesMinutos: json['tolerancia_antes'] as int? ?? 15,
      toleranciaDespuesMinutos: json['tolerancia_despues'] as int? ?? 15,
      estado: json['estado'] as String? ?? 'Pendiente',
      folio: json['folio'] as String?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      idSolicitante: json['id_solicitante'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_visita': tipoVisita,
      'es_grupal': esGrupal,
      'visitantes': visitantes.map((v) => v.toJson()).toList(),
      'lugar_encuentro': lugarDestino,
      'fecha_inicio': fechaVisita.toIso8601String(),
      'motivo_visita': motivoVisita,
      'tolerancia_antes': toleranciaAntesMinutos,
      'tolerancia_despues': toleranciaDespuesMinutos,
    };
  }
}

class CatalogoModel {
  final int id;
  final String nombre;

  const CatalogoModel({
    required this.id,
    required this.nombre,
  });

  factory CatalogoModel.fromJson(Map<String, dynamic> json) {
    return CatalogoModel(
      id: json['id'] as int? ?? 0,
      nombre: json['nombre'] as String? ?? '',
    );
  }
}