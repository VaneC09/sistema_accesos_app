// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : logout_dialog.dart
// Módulo    : features/auth/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Diálogo de confirmación de cierre de sesión — RF-012
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<bool?> mostrar(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.baseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Cerrar sesión',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const Text(
        AppStrings.preguntaCerrarSesion,
        style: TextStyle(color: AppColors.onyxGrey),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            AppStrings.botonCancelar,
            style: TextStyle(color: AppColors.headingDark),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
            foregroundColor: AppColors.baseSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(AppStrings.botonCerrarSesion),
        ),
      ],
    );
  }
}