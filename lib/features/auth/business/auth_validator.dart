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
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exceptions.dart';

class AuthValidator {
  AuthValidator._();

  // Valida campos de login institucional — SIN CAMBIOS
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

  // Valida campos de login de vigilante — ¡VERSIÓN MEJORADA Y OPTIMIZADA! 👍
  static void validarLoginVigilante(String telefono, String area) {
    if (telefono.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Ingresa tu número de teléfono',
      );
    }

    // Verifica que sean exactamente 10 dígitos numéricos en una sola línea
    if (!RegExp(r'^\d{10}$').hasMatch(telefono.trim())) {
      throw const ValidationException(
        mensaje: 'El teléfono debe tener exactamente 10 dígitos',
      );
    }

    if (area.trim().isEmpty) {
      throw const ValidationException(
        mensaje: 'Selecciona tu área',
      );
    }
  }

  // Determina el rol según datos del SAM — SIN CAMBIOS
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