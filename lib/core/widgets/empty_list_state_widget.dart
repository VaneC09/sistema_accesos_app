// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : empty_list_state_widget.dart
// Módulo    : core/widgets
// Descripción: Estado vacío reutilizable para listas paginadas.
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class EmptyListStateWidget extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final String? accionTexto;
  final VoidCallback? onAccion;
  final Color? colorIcono;

  const EmptyListStateWidget({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.accionTexto,
    this.onAccion,
    this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorIcono ?? AppColors.headingSky;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 56, color: color),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.deepNavy,
              ),
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitulo!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutralGrey,
                  height: 1.4,
                ),
              ),
            ],
            if (accionTexto != null && onAccion != null) ...[
              const SizedBox(height: AppSpacing.lg),
              TextButton.icon(
                onPressed: onAccion,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.primaryCoral,
                ),
                label: Text(
                  accionTexto!,
                  style: const TextStyle(
                    color: AppColors.primaryCoral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
