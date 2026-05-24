// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : error_message_widget.dart
// Módulo    : core/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Widget de error institucional reutilizable — MPF-OMEGA-04 §7.4
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class ErrorMessageWidget extends StatelessWidget {
  final String mensaje;
  final VoidCallback? onReintentar;

  const ErrorMessageWidget({
    super.key,
    required this.mensaje,
    this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.actionRed,
              size: AppSpacing.iconoLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onyxGrey,
              ),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: onReintentar,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primaryCoral,
                ),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(color: AppColors.primaryCoral),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}