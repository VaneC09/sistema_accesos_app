// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : cancel_visit_dialog.dart
// Módulo    : features/visit_request/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Diálogo de confirmación de cancelación de visita — RF-015
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class CancelVisitDialog extends StatelessWidget {
  const CancelVisitDialog({super.key});

  static Future<bool?> mostrar(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const CancelVisitDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.baseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      title: const Text(
        'Cancelar solicitud',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const Text(
        '¿Desea cancelar esta solicitud?',
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
            backgroundColor: AppColors.actionRed,
            foregroundColor: AppColors.baseSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ),
          child: const Text('Cancelar visita'),
        ),
      ],
    );
  }
}