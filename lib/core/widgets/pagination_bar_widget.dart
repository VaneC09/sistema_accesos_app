// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : pagination_bar_widget.dart
// Módulo    : core/widgets
// Descripción: Barra de índices y navegación de paginación.
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../models/paginacion_model.dart';

class PaginationBarWidget extends StatelessWidget {
  final PaginacionModel paginacion;
  final ValueChanged<int> onPaginaSeleccionada;
  final bool cargando;

  const PaginationBarWidget({
    super.key,
    required this.paginacion,
    required this.onPaginaSeleccionada,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    if (paginacion.totalRegistros <= 0) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      shadowColor: AppColors.deepNavy.withValues(alpha: 0.12),
      color: AppColors.baseSurface,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.primaryCoral.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          gradient: LinearGradient(
            colors: [
              AppColors.baseSurface,
              AppColors.subtleWarm.withValues(alpha: 0.6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 14,
                  color: AppColors.headingDark.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  '${paginacion.totalRegistros} registros · '
                  'página ${paginacion.paginaActual} de ${paginacion.totalPaginas}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.headingDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cargando) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryCoral,
                    ),
                  ),
                ],
              ],
            ),
            if (paginacion.muestraControles) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _BotonFlecha(
                    icono: Icons.first_page_rounded,
                    habilitado: paginacion.hayAnterior && !cargando,
                    onTap: () => onPaginaSeleccionada(1),
                  ),
                  _BotonFlecha(
                    icono: Icons.chevron_left_rounded,
                    habilitado: paginacion.hayAnterior && !cargando,
                    onTap: () =>
                        onPaginaSeleccionada(paginacion.paginaActual - 1),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: paginacion.indicesVisibles.map((pagina) {
                          final seleccionada =
                              pagina == paginacion.paginaActual;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              child: Material(
                                color: seleccionada
                                    ? AppColors.primaryCoral
                                    : AppColors.baseSurface,
                                elevation: seleccionada ? 2 : 0,
                                shadowColor: AppColors.primaryCoral
                                    .withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSmall,
                                ),
                                child: InkWell(
                                  onTap: cargando || seleccionada
                                      ? null
                                      : () => onPaginaSeleccionada(pagina),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSmall,
                                  ),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSmall,
                                      ),
                                      border: Border.all(
                                        color: seleccionada
                                            ? AppColors.primaryCoral
                                            : AppColors.headingSky
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(
                                      '$pagina',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: seleccionada
                                            ? AppColors.baseSurface
                                            : AppColors.headingDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  _BotonFlecha(
                    icono: Icons.chevron_right_rounded,
                    habilitado: paginacion.haySiguiente && !cargando,
                    onTap: () =>
                        onPaginaSeleccionada(paginacion.paginaActual + 1),
                  ),
                  _BotonFlecha(
                    icono: Icons.last_page_rounded,
                    habilitado: paginacion.haySiguiente && !cargando,
                    onTap: () =>
                        onPaginaSeleccionada(paginacion.totalPaginas),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BotonFlecha extends StatelessWidget {
  final IconData icono;
  final bool habilitado;
  final VoidCallback onTap;

  const _BotonFlecha({
    required this.icono,
    required this.habilitado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: habilitado
          ? AppColors.primaryCoral.withValues(alpha: 0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      child: InkWell(
        onTap: habilitado ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icono,
            size: 22,
            color: habilitado ? AppColors.primaryCoral : AppColors.neutralGrey,
          ),
        ),
      ),
    );
  }
}
