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
    final limpio = codigo.trim().toUpperCase();
    if (limpio.isEmpty) {
      throw const ValidationException(mensaje: 'Código QR vacío');
    }
    if (!RegExp(r'^VIS-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(limpio)) {
      throw const ValidationException(
        mensaje: 'El código QR no es válido para este sistema',
      );
    }
  }

  static void validarCodigoNumerico(String codigo) {
    final limpio = codigo.trim().toUpperCase();
    if (limpio.isEmpty) {
      throw const ValidationException(mensaje: 'Ingresa el código QR');
    }
    // Acepta VIS-XXXX-XXXX (ya ensamblado por el dialog)
    if (!RegExp(r'^VIS-[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(limpio)) {
      throw const ValidationException(
        mensaje: 'Formato inválido. Ejemplo: VIS-0491-6013',
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