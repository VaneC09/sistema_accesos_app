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

  // Valida que el código QR no esté vacío
  static void validarCodigoQr(String codigo) {
    if (codigo.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'El código QR no puede estar vacío',
      );
    }
  }

  // Valida código numérico de 8 dígitos — RF-022
  static void validarCodigoNumerico(String codigo) {
    if (codigo.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Ingrese el código numérico de 8 dígitos',
      );
    }

    if (codigo.trim().length != 8) {
      throw const ValidationException(
        mensaje: 'El código debe tener exactamente 8 dígitos',
      );
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(codigo.trim())) {
      throw const ValidationException(
        mensaje: 'El código solo debe contener dígitos',
      );
    }
  }

  // Valida que el teléfono del vigilante esté registrado
  static void validarTelefonoVigilante(String telefono) {
    if (telefono.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'El teléfono del vigilante es requerido',
      );
    }
  }
}