// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_validator.dart
// Módulo    : features/auth/business
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Validaciones de negocio para autenticación — RF-009, RF-010
// =============================================================================

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';

class AuthValidator {
  AuthValidator._();

  // Valida campos de login institucional
  static void validarLogin(String usuario, String contrasena) {
    if (usuario.isEmpty || contrasena.isEmpty) {
      throw const ValidationException(
        mensaje: AppStrings.errorCamposVacios,
      );
    }

    if (!usuario.endsWith(AppConfig.dominioInstitucional)) {
      throw const ValidationException(
        mensaje: AppStrings.errorDominioInvalido,
      );
    }
  }

  // Valida campos de login de vigilante
  static void validarLoginVigilante(String telefono, String area) {
    if (telefono.isEmpty || area.isEmpty) {
      throw const ValidationException(
        mensaje: AppStrings.errorCamposVigilante,
      );
    }

    if (telefono.length != 10) {
      throw const ValidationException(
        mensaje: 'El número de teléfono debe tener 10 dígitos',
      );
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(telefono)) {
      throw const ValidationException(
        mensaje: 'El número de teléfono solo debe contener dígitos',
      );
    }
  }

  // Determina el rol según datos del SAM
  static String determinarRol({
    required String puesto,
    required int idDepartamento,
  }) {
    // ID del departamento de Recursos Materiales en el SAM
    const int idRecursosMateriales = 5;

    final puestoLower = puesto.toLowerCase();

    if (puestoLower.contains('jefe') ||
        puestoLower.contains('director') ||
        puestoLower.contains('subdirector')) {
      return 'jefe';
    }

    if (idDepartamento == idRecursosMateriales) {
      return 'recursos_materiales';
    }

    return 'empleado';
  }
}