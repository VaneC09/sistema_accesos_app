// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_request_validator.dart
// Módulo    : features/visit_request/business
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Validaciones de negocio para solicitudes — RF-013, RF-014
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/constants/app_strings.dart';

class VisitRequestValidator {
  VisitRequestValidator._();

  // Valida nombre del visitante
  static void validarNombre(String nombre) {
    if (nombre.trim().length < 5) {
      throw const ValidationException(
        mensaje: AppStrings.errorNombreMinimo,
      );
    }
  }

  // Valida correo del visitante
  static void validarCorreo(String correo) {
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
    if (!regex.hasMatch(correo)) {
      throw const ValidationException(
        mensaje: AppStrings.errorCorreoInvalido,
      );
    }
  }

  // Valida que no haya correos duplicados en grupo
  static void validarCorreosDuplicados(List<String> correos) {
    final unicos = correos.toSet();
    if (unicos.length != correos.length) {
      throw const ValidationException(
        mensaje: AppStrings.errorCorreoDuplicado,
      );
    }
  }

  // Valida fecha de visita no sea pasada
  static void validarFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaSoloDia = DateTime(fecha.year, fecha.month, fecha.day);

    if (fechaSoloDia.isBefore(hoy)) {
      throw const ValidationException(
        mensaje: 'La fecha de visita no puede ser anterior a la fecha actual',
      );
    }
  }


  // Valida campos completos de solicitud
  static void validarSolicitud({
    required String lugarDestino,
    required String motivoVisita,
    required DateTime? fechaVisita,
    required String tipoVisita,
  }) {
    if (lugarDestino.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Ingrese el lugar destino',
      );
    }
    if (motivoVisita.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Ingrese el motivo de la visita',
      );
    }
    if (fechaVisita == null) {
      throw const ValidationException(
        mensaje: AppStrings.errorCamposIncompletos,
      );
    }
    if (tipoVisita.isEmpty) {
      throw const ValidationException(
        mensaje: AppStrings.errorTipoVisita,
      );
    }
    validarFecha(fechaVisita);
  }
}