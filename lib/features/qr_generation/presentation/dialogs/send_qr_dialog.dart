// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : send_qr_dialog.dart
// Módulo    : features/qr_generation/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Diálogo de confirmación de envío QR — RF-021, RF-036
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class SendQrDialog extends StatelessWidget {
  const SendQrDialog({super.key});

  static Future<bool?> mostrar(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const SendQrDialog(),
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
        'Enviar pase QR',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: const Text(
        AppStrings.preguntaEnviarQr,
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
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
            foregroundColor: AppColors.baseSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ),
          icon: const Icon(Icons.send_rounded),
          label: const Text(AppStrings.botonMandar),
        ),
      ],
    );
  }
}