// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : estado_filtro_bar_widget.dart
// Módulo    : core/widgets
// Descripción: Barra horizontal de chips por estado de solicitud.
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/filtro_estado_solicitud.dart';

class EstadoFiltroBarWidget extends StatelessWidget {
  final String? filtroSeleccionado;
  final ValueChanged<String?> onFiltroChanged;

  const EstadoFiltroBarWidget({
    super.key,
    required this.filtroSeleccionado,
    required this.onFiltroChanged,
  });

  IconData _iconoPara(String estado) {
    switch (estado) {
      case FiltroEstadoSolicitud.todos:
        return Icons.grid_view_rounded;
      case FiltroEstadoSolicitud.pendiente:
        return Icons.hourglass_top_rounded;
      case FiltroEstadoSolicitud.autorizada:
        return Icons.verified_rounded;
      case FiltroEstadoSolicitud.rechazada:
        return Icons.block_rounded;
      case FiltroEstadoSolicitud.cancelada:
        return Icons.cancel_rounded;
      default:
        return Icons.filter_list_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.baseSurface,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: AppColors.headingDark.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Filtrar por estado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.headingDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              itemCount: FiltroEstadoSolicitud.chips.length,
              itemBuilder: (context, index) {
                final estado = FiltroEstadoSolicitud.chips[index];
                final seleccionado = estado == FiltroEstadoSolicitud.todos
                    ? filtroSeleccionado == null
                    : filtroSeleccionado == estado;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    selected: seleccionado,
                    showCheckmark: false,
                    avatar: Icon(
                      _iconoPara(estado),
                      size: 16,
                      color: seleccionado
                          ? AppColors.baseSurface
                          : AppColors.headingDark,
                    ),
                    label: Text(
                      estado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: seleccionado
                            ? AppColors.baseSurface
                            : AppColors.headingDark,
                      ),
                    ),
                    selectedColor: AppColors.primaryCoral,
                    backgroundColor: AppColors.subtleWarm,
                    side: BorderSide(
                      color: seleccionado
                          ? AppColors.primaryCoral
                          : AppColors.headingSky.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    onSelected: (_) {
                      onFiltroChanged(
                        estado == FiltroEstadoSolicitud.todos ? null : estado,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
