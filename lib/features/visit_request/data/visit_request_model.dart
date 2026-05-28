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
      nombre: json['nombre']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      correo: json['correo']?.toString() ??
          json['correo_personal']?.toString() ??
          json['email']?.toString() ??
          '',
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
    final numeroVisitantes = _toInt(
      json['numero_visitantes'],
      defaultValue: 1,
    );

    final estadoId = _toInt(
      json['id_estado_solicitud'],
      defaultValue: 1,
    );

    String tipo = json['tipo_visita']?.toString() ?? '';

    if (tipo.isEmpty && json['tipo'] is Map<String, dynamic>) {
      final tipoJson = json['tipo'] as Map<String, dynamic>;
      tipo = tipoJson['nombre']?.toString() ??
          tipoJson['tipo']?.toString() ??
          tipoJson['descripcion']?.toString() ??
          '';
    }

    if (tipo.isEmpty) {
      tipo = 'Personal';
    }

    return VisitRequestModel(
      idSolicitud: _toNullableInt(json['id_solicitud']),
      tipoVisita: tipo,
      esGrupal: numeroVisitantes > 1,
      visitantes: (json['visitantes'] as List<dynamic>? ?? [])
          .map((v) => VisitanteModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      lugarDestino: json['lugar_encuentro']?.toString() ?? '',
      fechaVisita: DateTime.tryParse(
        json['fecha_inicio']?.toString() ?? '',
      ) ??
          DateTime.now(),
      motivoVisita: json['motivo_visita']?.toString() ?? '',
      toleranciaAntesMinutos: _toInt(
        json['tolerancia_antes'],
        defaultValue: 15,
      ),
      toleranciaDespuesMinutos: _toInt(
        json['tolerancia_despues'],
        defaultValue: 15,
      ),
      estado: _mapearEstado(estadoId),
      folio: json['folio']?.toString() ??
          'VIS-${json['id_solicitud']?.toString().padLeft(8, '0') ?? '00000000'}',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.tryParse(json['fecha_creacion'].toString())
          : null,
      idSolicitante: _toNullableInt(json['id_solicitante']),
    );
  }

  static String _mapearEstado(int id) {
    switch (id) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Autorizada';
      case 3:
        return 'Rechazada';
      case 4:
        return 'Cancelada';
      default:
        return 'Pendiente';
    }
  }

  static int _toInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'tipo_visita': tipoVisita,
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
      id: json['id'] as int? ??
          json['id_tipo_solicitud'] as int? ??
          0,
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}