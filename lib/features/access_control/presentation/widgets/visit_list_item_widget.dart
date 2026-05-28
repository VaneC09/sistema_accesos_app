// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visit_list_item_widget.dart
// Módulo    : features/access_control/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Item de lista de visitas del día — RF-025
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/access_model.dart';

class VisitListItemWidget extends StatelessWidget {
  final VisitaHoyModel visita;
  final VoidCallback? onTap;

  const VisitListItemWidget({
    super.key,
    required this.visita,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.baseSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(color: AppColors.surface),
        ),
        child: Row(
          children: [
            // Indicadores de entrada/salida
            Column(
              children: [
                Icon(
                  Icons.login_rounded,
                  size: 20,
                  color: visita.entradaRegistrada
                      ? AppColors.successGreen
                      : AppColors.surface,
                ),
                const SizedBox(height: AppSpacing.xs),
                Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: visita.salidaRegistrada
                      ? AppColors.successGreen
                      : AppColors.surface,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visita.nombreVisitante,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    visita.motivoVisita,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.steelBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatearHora(visita.horaVisita),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: _colorEstado(visita.estado).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                visita.estado,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _colorEstado(visita.estado),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'autorizada':
        return AppColors.successGreen;
      case 'pendiente':
        return AppColors.primaryCoral;
      default:
        return AppColors.headingDark;
    }
  }

  String _formatearHora(DateTime hora) {
    return '${hora.hour}:${hora.minute.toString().padLeft(2, '0')}';
  }
}