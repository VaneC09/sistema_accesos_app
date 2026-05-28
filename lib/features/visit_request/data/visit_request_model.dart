/// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_model.dart
// Módulo    : features/visit_request/data
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.1
// Cambio    : Corrige mapeo de tipo de visita.
//              Consulta NO pertenece a solicitud normal.
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

    final idTipoSolicitud = _toInt(
      json['id_tipo_solicitud'],
      defaultValue: 3,
    );

    String tipo = json['tipo_visita']?.toString() ?? '';

    // En backend, json['tipo'] puede venir como Individual / Grupal.
    // Eso NO es el tipo real de visita para móvil.
    // Por eso se usa id_tipo_solicitud.
    if (tipo.isEmpty ||
        tipo.toLowerCase().trim() == 'individual' ||
        tipo.toLowerCase().trim() == 'grupal') {
      tipo = _mapearTipoSolicitud(idTipoSolicitud);
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
      default:
        return 'Pendiente';
    }
  }

  static String _mapearTipoSolicitud(int id) {
    switch (id) {
      case 1:
        return 'Proveedor';
      case 2:
        return 'Institucional / Negocios';
      case 3:
        return 'Personal';
      default:
        return 'Personal';
    }
  }

  static int _obtenerIdTipoSolicitud(String tipo) {
    final tipoNormalizado = tipo.toLowerCase().trim();

    if (tipoNormalizado.contains('proveedor')) {
      return 1;
    }

    if (tipoNormalizado.contains('institucional') ||
        tipoNormalizado.contains('negocios')) {
      return 2;
    }

    if (tipoNormalizado.contains('personal')) {
      return 3;
    }

    return 3;
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
      'id_tipo_solicitud': _obtenerIdTipoSolicitud(tipoVisita),
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