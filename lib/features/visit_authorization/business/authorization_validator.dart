// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_validator.dart
// Módulo    : features/visit_authorization/business
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Validaciones de autorización — RF-019, RF-020
// =============================================================================

import '../../../core/errors/app_exceptions.dart';

class AuthorizationValidator {
  AuthorizationValidator._();

  static void validarAccionAutorizacion(String estado) {
    if (estado != 'Pendiente') {
      throw const ValidationException(
        mensaje: 'La solicitud ya fue procesada',
      );
    }
  }
}