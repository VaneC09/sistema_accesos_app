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
    final tipoJson = json['tipo'] is Map<String, dynamic>
        ? json['tipo'] as Map<String, dynamic>
        : <String, dynamic>{};

    final estadoJson = json['estado'] is Map<String, dynamic>
        ? json['estado'] as Map<String, dynamic>
        : <String, dynamic>{};

    final solicitanteJson = json['solicitante'] is Map<String, dynamic>
        ? json['solicitante'] as Map<String, dynamic>
        : <String, dynamic>{};

    final idTipoSolicitud = _toInt(json['id_tipo_solicitud']);

    return AuthorizationModel(
      idSolicitud: _toInt(json['id_solicitud']),

      folio: json['folio']?.toString() ??
          'VIS-${json['id_solicitud']?.toString().padLeft(8, '0') ?? '00000000'}',

      nombreAnfitrion: json['nombre_solicitante']?.toString() ??
          solicitanteJson['name']?.toString() ??
          solicitanteJson['nombre']?.toString() ??
          json['nombre_anfitrion']?.toString() ??
          'Sin nombre',

      correoAnfitrion: json['correo_solicitante']?.toString() ??
          solicitanteJson['email']?.toString() ??
          json['correo_anfitrion']?.toString() ??
          '',

      tipoVisita: _obtenerTipoVisita(
        json: json,
        tipoJson: tipoJson,
        idTipoSolicitud: idTipoSolicitud,
      ),

      motivoVisita: json['motivo_visita']?.toString() ?? '',

      lugarDestino: json['lugar_encuentro']?.toString() ?? '',

      fechaVisita: DateTime.tryParse(
        json['fecha_inicio']?.toString() ?? '',
      ) ??
          DateTime.now(),

      toleranciaAntes: _toInt(
        json['tolerancia_antes'],
        defaultValue: 15,
      ),

      toleranciaDespues: _toInt(
        json['tolerancia_despues'],
        defaultValue: 15,
      ),

      visitantes: (json['visitantes'] as List<dynamic>? ?? [])
          .map((v) => VisitanteAuthModel.fromJson(v as Map<String, dynamic>))
          .toList(),

      estado: _obtenerEstado(
        json: json,
        estadoJson: estadoJson,
      ),

      fechaCreacion: DateTime.tryParse(
        json['fecha_creacion']?.toString() ?? '',
      ) ??
          DateTime.now(),
    );
  }

  static String _obtenerTipoVisita({
    required Map<String, dynamic> json,
    required Map<String, dynamic> tipoJson,
    required int idTipoSolicitud,
  }) {
    final tipoPlano = json['tipo_visita']?.toString().trim();
    final tipoNombre = tipoJson['nombre']?.toString().trim();
    final tipoDescripcion = tipoJson['descripcion']?.toString().trim();

    // En la app móvil antes se usaba Individual/Grupal como tipo,
    // pero en Laravel los tipos reales son Proveedor, Institucional / Negocios y Personal.
    if (tipoPlano != null &&
        tipoPlano.isNotEmpty &&
        tipoPlano.toLowerCase() != 'individual' &&
        tipoPlano.toLowerCase() != 'grupal') {
      return tipoPlano;
    }

    if (tipoNombre != null && tipoNombre.isNotEmpty) {
      return tipoNombre;
    }

    if (tipoDescripcion != null && tipoDescripcion.isNotEmpty) {
      return tipoDescripcion;
    }

    return _mapearTipoSolicitud(idTipoSolicitud);
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
        return 'Sin tipo';
    }
  }

  static String _obtenerEstado({
    required Map<String, dynamic> json,
    required Map<String, dynamic> estadoJson,
  }) {
    final estadoPlano = json['estado_nombre']?.toString().trim();
    final estadoRelacion = estadoJson['nombre']?.toString().trim();

    if (estadoPlano != null && estadoPlano.isNotEmpty) {
      return _normalizarEstado(estadoPlano);
    }

    if (estadoRelacion != null && estadoRelacion.isNotEmpty) {
      return _normalizarEstado(estadoRelacion);
    }

    return _mapearEstado(
      _toInt(json['id_estado_solicitud'], defaultValue: 1),
    );
  }

  static String _normalizarEstado(String estado) {
    final estadoLower = estado.toLowerCase().trim();

    if (estadoLower == 'pendiente') {
      return 'Pendiente';
    }

    if (estadoLower == 'autorizada' || estadoLower == 'aprobada') {
      return 'Autorizada';
    }

    // Si en Laravel no existe "Rechazada" y manejan ese caso como "Cancelada",
    // Flutter también lo muestra como Cancelada.
    if (estadoLower == 'rechazada' ||
        estadoLower == 'rechazado' ||
        estadoLower == 'cancelada' ||
        estadoLower == 'cancelado') {
      return 'Cancelada';
    }

    return estado;
  }

  static String _mapearEstado(int id) {
    switch (id) {
      case 1:
        return 'Pendiente';
      case 2:
        return 'Autorizada';
      case 3:
        return 'Cancelada';
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
}

class VisitanteAuthModel {
  final String nombre;
  final String apellidos;
  final String correo;

  const VisitanteAuthModel({
    required this.nombre,
    this.apellidos = '',
    required this.correo,
  });

  factory VisitanteAuthModel.fromJson(Map<String, dynamic> json) {
    return VisitanteAuthModel(
      nombre: json['nombre']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      correo: json['correo']?.toString() ??
          json['correo_personal']?.toString() ??
          json['email']?.toString() ??
          '',
    );
  }
}