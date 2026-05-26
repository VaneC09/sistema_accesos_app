// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_model.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelos de control de acceso — RF-022, RF-025
// =============================================================================

// Resultado del escaneo de QR
class QrScanResultModel {
  final String folio;
  final String nombreVisitante;
  final String lugarDestino;
  final String estado;
  final String tipoAcceso; // 'entrada' o 'salida'
  final bool accesoConcedido;
  final String? motivoRechazo;
  final DateTime? horaToleranciaInicio;
  final DateTime? horaToleranciaFin;
  final bool llegaTarde;
  final bool llegaAnticiapdo;

  const QrScanResultModel({
    required this.folio,
    required this.nombreVisitante,
    required this.lugarDestino,
    required this.estado,
    required this.tipoAcceso,
    required this.accesoConcedido,
    this.motivoRechazo,
    this.horaToleranciaInicio,
    this.horaToleranciaFin,
    this.llegaTarde = false,
    this.llegaAnticiapdo = false,
  });
  factory QrScanResultModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final sv = data['solicitud_visitante'] as Map<String, dynamic>?;
    final visitante = sv?['visitante'] as Map<String, dynamic>?;
    final solicitud = sv?['solicitud'] as Map<String, dynamic>?;

    final nombre = visitante != null
        ? '${visitante['nombre']} ${visitante['apellidos']}'
        : '';
    final lugar = solicitud?['lugar_encuentro'] as String? ?? '';
    final idQr = data['id_qr'] as int? ?? 0;

    return QrScanResultModel(
      folio: 'VIS-${idQr.toString().padLeft(8, '0')}',
      nombreVisitante: nombre,
      lugarDestino: lugar,
      estado: 'Autorizada',
      tipoAcceso: 'entrada',
      accesoConcedido: true,
      llegaTarde: false,
      llegaAnticiapdo: false,
    );
  }
}

// Modelo de visita del día para el vigilante
class VisitaHoyModel {
  final String folio;
  final String nombreVisitante;
  final String lugarDestino;
  final String tipoVisita;
  final DateTime horaVisita;
  final String estado;
  final bool entradaRegistrada;
  final bool salidaRegistrada;

  const VisitaHoyModel({
    required this.folio,
    required this.nombreVisitante,
    required this.lugarDestino,
    required this.tipoVisita,
    required this.horaVisita,
    required this.estado,
    required this.entradaRegistrada,
    required this.salidaRegistrada,
  });

  factory VisitaHoyModel.fromJson(Map<String, dynamic> json) {
    return VisitaHoyModel(
      folio: json['folio'] as String? ?? '',
      nombreVisitante: json['nombre_visitante'] as String? ?? '',
      lugarDestino: json['lugar_destino'] as String? ?? '',
      tipoVisita: json['tipo_visita'] as String? ?? '',
      horaVisita: DateTime.parse(
        json['hora_visita'] as String? ?? DateTime.now().toIso8601String(),
      ),
      estado: json['estado'] as String? ?? '',
      entradaRegistrada: json['entrada_registrada'] as bool? ?? false,
      salidaRegistrada: json['salida_registrada'] as bool? ?? false,
    );
  }
}

// Modelo para registro manual
class RegistroManualModel {
  final String codigoNumerico;
  final String telefono;
  final String area;

  const RegistroManualModel({
    required this.codigoNumerico,
    required this.telefono,
    required this.area,
  });

  Map<String, dynamic> toJson() {
    return {
      'codigo_numerico': codigoNumerico,
      'telefono': telefono,
      'area': area,
    };
  }
}