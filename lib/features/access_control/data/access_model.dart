// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_model.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Modelos de control de acceso — RF-022, RF-025
// =============================================================================
// 1. MODELO: RESULTADO DE ESCANEO QR
class QrScanResultModel {
  final int idQr;
  final String folio;
  final String nombreVisitante;
  final String correoVisitante;
  final String motivoVisita;
  final String vigenciaInicio;
  final String vigenciaFin;
  final String accionDisponible; // 'entrada' o 'salida'
  final bool accesoConcedido;
  final String? motivoRechazo;

  const QrScanResultModel({
    required this.idQr,
    required this.folio,
    required this.nombreVisitante,
    required this.correoVisitante,
    required this.motivoVisita,
    required this.vigenciaInicio,
    required this.vigenciaFin,
    required this.accionDisponible,
    required this.accesoConcedido,
    this.motivoRechazo,
  });

  // Getters para mantener compatibilidad con código/vistas anteriores
  String get tipoAcceso => accionDisponible;
  bool get llegaTarde => false;
  bool get llegaAnticipado => false;

  factory QrScanResultModel.fromJson(Map<String, dynamic> json) {
    // El datasource ya desenvuelve 'data' antes de llamar aquí.
    // json ES el objeto plano: { id_qr, acceso_concedido, visitante, solicitud, ... }
    final visitante = json['visitante'] as Map<String, dynamic>? ?? {};
    final solicitud = json['solicitud'] as Map<String, dynamic>? ?? {};

    return QrScanResultModel(
      idQr:             json['id_qr']              as int?    ?? 0,
      folio:            'QR-${json['id_qr'] ?? 0}',
      nombreVisitante:  '${visitante['nombre'] ?? ''} ${visitante['apellidos'] ?? ''}'.trim(),
      correoVisitante:  visitante['correo_personal'] as String? ?? '',
      motivoVisita:     solicitud['motivo_visita']   as String? ?? '',
      vigenciaInicio:   solicitud['vigencia_inicio'] as String? ?? '',
      vigenciaFin:      solicitud['vigencia_final']  as String? ?? '',
      accionDisponible: json['accion_disponible']    as String? ?? 'entrada',
      accesoConcedido:  json['acceso_concedido']     as bool?   ?? false,
      motivoRechazo:    json['motivo_rechazo']       as String?,
    );
  }
}

// 2. MODELO: VISITA DEL DÍA PARA EL VIGILANTE
class VisitaHoyModel {
  final String folio;
  final String nombreVisitante;
  final String motivoVisita; // Antes era lugarDestino, adaptado al nuevo flujo
  final String tipoVisita;
  final DateTime horaVisita;
  final String estado;
  final bool entradaRegistrada;
  final bool salidaRegistrada;

  const VisitaHoyModel({
    required this.folio,
    required this.nombreVisitante,
    required this.motivoVisita,
    required this.tipoVisita,
    required this.horaVisita,
    required this.estado,
    required this.entradaRegistrada,
    required this.salidaRegistrada,
  });

  factory VisitaHoyModel.fromJson(Map<String, dynamic> json) {
    // Laravel manda 'visitantes' como lista; tomamos el primero
    final visitantes = json['visitantes'] as List<dynamic>? ?? [];
    final primerVisitante = visitantes.isNotEmpty
        ? visitantes.first as Map<String, dynamic>
        : <String, dynamic>{};

    final nombre = primerVisitante.isNotEmpty
        ? '${primerVisitante['nombre']} ${primerVisitante['apellidos']}'.trim()
        : 'Sin nombre';

    final estado = json['estado'] as String? ?? 'autorizada';

    return VisitaHoyModel(
      folio:             json['folio']           as String? ?? '',
      nombreVisitante:   nombre,
      motivoVisita:      json['lugar_encuentro'] as String? ?? '', // ← fix
      tipoVisita:        'Visita',                                   // fijo, Laravel no lo manda
      horaVisita: DateTime.tryParse(
        json['hora_inicio'] as String? ?? '',                        // ← fix
      ) ?? DateTime.now(),
      estado:            estado,
      entradaRegistrada: estado == 'dentro' || estado == 'salio',   // ← derivado
      salidaRegistrada:  estado == 'salio',                          // ← derivado
    );
  }
}

// 3. MODELO: REGISTRO MANUAL
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