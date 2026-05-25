// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_generation_validator.dart
// Módulo    : features/qr_generation/business
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Validaciones de generación QR — RF-021, RF-037
// =============================================================================

import '../../../core/errors/app_exceptions.dart';
import '../../../core/constants/app_strings.dart';
import '../data/qr_generation_model.dart';

class QrGenerationValidator {
  QrGenerationValidator._();

  // Valida que se pueda reenviar el QR
  static void validarReenvio(QrGenerationModel qr) {
    if (!qr.puedeReenviar) {
      throw const ValidationException(
        mensaje: AppStrings.limiteReenvios,
      );
    }
  }

  // Valida que la solicitud esté autorizada
  static void validarEstadoAutorizado(String estado) {
    if (estado.toLowerCase() != 'autorizada') {
      throw const ValidationException(
        mensaje: 'La solicitud debe estar autorizada para generar el QR',
      );
    }
  }
}