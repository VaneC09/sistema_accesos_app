// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : authorization_card_widget.dart
// Módulo    : features/visit_authorization/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Tarjeta de solicitud pendiente de autorización — RF-019
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/authorization_model.dart';

class AuthorizationCardWidget extends StatelessWidget {
  final AuthorizationModel solicitud;
  final VoidCallback? onTap;

  const AuthorizationCardWidget({
    super.key,
    required this.solicitud,
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
          border: Border.all(color: AppColors.warningOrange),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  solicitud.tipoVisita,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: const Text(
                    'Pendiente',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryCoral,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Anfitrión
            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: AppColors.neutralGrey,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  solicitud.nombreAnfitrion,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.steelBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Lugar
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.neutralGrey,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  solicitud.lugarDestino,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.steelBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Fecha
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.neutralGrey,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _formatearFecha(solicitud.fechaVisita),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.steelBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Visitantes
            Row(
              children: [
                const Icon(
                  Icons.group_outlined,
                  size: 16,
                  color: AppColors.neutralGrey,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${solicitud.visitantes.length} visitante(s)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.steelBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}