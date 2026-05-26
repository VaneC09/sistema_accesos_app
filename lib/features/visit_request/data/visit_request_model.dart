/// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_model.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.0
// =============================================================================

class VisitanteModel {
  final String nombre;
  final String apellidos;
  final String correo;

  const VisitanteModel({
    required this.nombre,
    this.apellidos = '',
    required this.correo,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) {
    return VisitanteModel(
      nombre: json['nombre'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      correo: json['correo_personal'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
    };
  }
}

class VisitRequestModel {
  final int? idSolicitud;
  final String tipoVisita; // <-- NUEVO CAMPO
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
    required this.tipoVisita, // <-- NUEVO CAMPO REQUERIDO
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
      tipoVisita: json['tipo_visita'] as String? ?? 'Personal', // <-- MAPEO DESDE JSON
      esGrupal: (json['numero_visitantes'] as int? ?? 1) > 1,
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
      estado: _mapearEstado(json['id_estado_solicitud'] as int? ?? 1),
      folio: 'VIS-${json['id_solicitud']?.toString().padLeft(8, '0') ?? '00000000'}',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'] as String)
          : null,
      idSolicitante: json['id_solicitante'] as int?,
    );
  }

  static String _mapearEstado(int id) {
    switch (id) {
      case 1: return 'Pendiente';
      case 2: return 'Autorizada';
      case 3: return 'Rechazada';
      case 4: return 'Cancelada';
      default: return 'Pendiente';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_visita': tipoVisita, // <-- ENVÍO AL BACKEND
      'fecha_inicio': fechaVisita.toIso8601String(),
      'lugar_encuentro': lugarDestino,
      'motivo_visita': motivoVisita,
      'id_tipo_solicitud': esGrupal ? 2 : 1,
      'tolerancia_antes': toleranciaAntesMinutos,
      'tolerancia_despues': toleranciaDespuesMinutos,
      'numero_visitantes': visitantes.length,
      'visitantes': visitantes.map((v) => v.toJson()).toList(),
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