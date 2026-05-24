// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : loading_widget.dart
// Módulo    : core/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Widget de carga institucional reutilizable — MPF-OMEGA-04 §7.1.6
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class LoadingWidget extends StatelessWidget {
  final String? mensaje;

  const LoadingWidget({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primaryCoral,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              mensaje!,
              style: const TextStyle(
                color: AppColors.neutralGrey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}