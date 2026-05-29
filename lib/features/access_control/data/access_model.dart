// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : access_model.dart
// Módulo    : features/access_control/data
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.1.0
// =============================================================================

class QrScanResultModel {
  final int idQr;
  final String nombreVisitante;
  final String correoVisitante;
  final String motivoVisita;
  final String lugarEncuentro;
  final int toleranciaAntes;
  final int toleranciaDespues;
  final String vigenciaInicio;
  final String vigenciaFin;
  final String accionDisponible;
  final bool accesoConcedido;
  final String? motivoRechazo;
  final String nombreSolicitante;
  final String departamentoSolicitante;

  const QrScanResultModel({
    required this.idQr,
    required this.nombreVisitante,
    required this.correoVisitante,
    required this.motivoVisita,
    required this.lugarEncuentro,
    required this.toleranciaAntes,
    required this.toleranciaDespues,
    required this.vigenciaInicio,
    required this.vigenciaFin,
    required this.accionDisponible,
    required this.accesoConcedido,
    required this.nombreSolicitante,
    required this.departamentoSolicitante,
    this.motivoRechazo,
  });

  String get tipoAcceso => accionDisponible;
  bool get llegaTarde => false;

  factory QrScanResultModel.fromJson(Map<String, dynamic> json) {
    final visitante   = json['visitante']   as Map<String, dynamic>? ?? {};
    final solicitud   = json['solicitud']   as Map<String, dynamic>? ?? {};
    final solicitante = json['solicitante'] as Map<String, dynamic>? ?? {};

    return QrScanResultModel(
      idQr:                   json['id_qr']              as int?    ?? 0,
      nombreVisitante:        '${visitante['nombre'] ?? ''} ${visitante['apellidos'] ?? ''}'.trim(),
      correoVisitante:        visitante['correo_personal']  as String? ?? '',
      motivoVisita:           solicitud['motivo_visita']    as String? ?? '',
      lugarEncuentro:         solicitud['lugar_encuentro']  as String? ?? '',
      toleranciaAntes:        (solicitud['tolerancia_antes']   as num?)?.toInt() ?? 0,
      toleranciaDespues:      (solicitud['tolerancia_despues'] as num?)?.toInt() ?? 0,
      vigenciaInicio:         solicitud['vigencia_inicio']  as String? ?? '',
      vigenciaFin:            solicitud['vigencia_final']   as String? ?? '',
      accionDisponible:       json['accion_disponible']     as String? ?? 'entrada',
      accesoConcedido:        json['acceso_concedido']      as bool?   ?? false,
      motivoRechazo:          json['motivo_rechazo']        as String?,
      nombreSolicitante:      solicitante['nombre']         as String? ?? '',
      departamentoSolicitante:solicitante['departamento']   as String? ?? '',
    );
  }
}

// 2. MODELO: VISITA DEL DÍA
class VisitaHoyModel {
  final String folio;
  final String nombreVisitante;
  final String motivoVisita;
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
    final visitantes      = json['visitantes'] as List<dynamic>? ?? [];
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
      motivoVisita:      json['lugar_encuentro'] as String? ?? '',
      tipoVisita:        'Visita',
      horaVisita:        DateTime.tryParse(json['hora_inicio'] as String? ?? '') ?? DateTime.now(),
      estado:            estado,
      entradaRegistrada: estado == 'dentro' || estado == 'salio',
      salidaRegistrada:  estado == 'salio',
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

  Map<String, dynamic> toJson() => {
    'codigo_numerico': codigoNumerico,
    'telefono':        telefono,
    'area':            area,
  };
}