// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : list_stats_header_widget.dart
// Módulo    : core/widgets
// Descripción: Cabecera con resumen de registros y paginación actual.
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/paginacion_model.dart';

class ListStatsHeaderWidget extends StatelessWidget {
  final String titulo;
  final PaginacionModel paginacion;
  final IconData icono;
  final Color? colorAcento;

  const ListStatsHeaderWidget({
    super.key,
    required this.titulo,
    required this.paginacion,
    this.icono = Icons.list_alt_rounded,
    this.colorAcento,
  });

  @override
  Widget build(BuildContext context) {
    final acento = colorAcento ?? AppColors.primaryCoral;
    final inicio = paginacion.totalRegistros == 0
        ? 0
        : ((paginacion.paginaActual - 1) * paginacion.porPagina) + 1;
    final fin = (inicio + paginacion.porPagina - 1)
        .clamp(0, paginacion.totalRegistros);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            acento.withValues(alpha: 0.12),
            AppColors.cloudBlue.withValues(alpha: 0.35),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: acento.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: acento.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(icono, color: acento, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  paginacion.totalRegistros == 0
                      ? 'Sin registros'
                      : 'Mostrando $inicio–$fin de ${paginacion.totalRegistros}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.headingDark,
                  ),
                ),
              ],
            ),
          ),
          if (paginacion.totalRegistros > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.baseSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                border: Border.all(color: acento.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${paginacion.paginaActual}/${paginacion.totalPaginas}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: acento,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
