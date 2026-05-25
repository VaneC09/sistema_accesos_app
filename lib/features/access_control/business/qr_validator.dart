// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_validator.dart
// Módulo    : features/access_control/business
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Validaciones de QR para control de acceso — RF-022, RF-042, RF-043
// =============================================================================

import '../../../core/errors/app_exceptions.dart';

class QrValidator {
  QrValidator._();

  static void validarCodigoQr(String codigo) {
    if (codigo.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'El código QR no puede estar vacío',
      );
    }
  }

  static void validarCodigoNumerico(String codigo) {
    if (codigo.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Ingrese el código de 8 caracteres',
      );
    }

    if (codigo.trim().length != 8) {
      throw const ValidationException(
        mensaje: 'El código debe tener exactamente 8 caracteres',
      );
    }
  }

  static void validarTelefonoVigilante(String telefono) {
    if (telefono.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'El teléfono del vigilante es requerido',
      );
    }
  }
}