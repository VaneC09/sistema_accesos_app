// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_result_widget.dart
// Módulo    : features/access_control/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Widget de resultado de escaneo QR — RF-022, RNF-33
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/access_model.dart';

class QrResultWidget extends StatelessWidget {
  final QrScanResultModel resultado;
  final VoidCallback? onExtenderTiempo;
  final VoidCallback? onNuevoEscaneo;

  const QrResultWidget({
    super.key,
    required this.resultado,
    this.onExtenderTiempo,
    this.onNuevoEscaneo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: resultado.accesoConcedido
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.actionRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(
          color: resultado.accesoConcedido
              ? AppColors.successGreen
              : AppColors.actionRed,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de resultado
          Icon(
            resultado.accesoConcedido
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            size: 72,
            color: resultado.accesoConcedido
                ? AppColors.successGreen
                : AppColors.actionRed,
          ),
          const SizedBox(height: AppSpacing.md),

          // Estado de acceso
          Text(
            resultado.accesoConcedido
                ? AppStrings.accesoPermitido
                : AppStrings.accesoDenegado,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: resultado.accesoConcedido
                  ? AppColors.successGreen
                  : AppColors.actionRed,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Nombre del visitante — mínimo 18pt según RNF-03
          Text(
            resultado.nombreVisitante,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.deepNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Lugar destino — mínimo 18pt según RNF-03
          Text(
            resultado.lugarDestino,
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.steelBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Folio
          Text(
            'Folio: ${resultado.folio}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutralGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tipo de acceso
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: resultado.tipoAcceso == 'entrada'
                  ? AppColors.headingSky
                  : AppColors.subtleWarm,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              resultado.tipoAcceso == 'entrada'
                  ? 'ENTRADA'
                  : 'SALIDA',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
          ),

          // Mensaje si llega tarde
          if (resultado.llegaTarde) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warningOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.primaryCoral,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    AppStrings.accesoFueraHorario,
                    style: TextStyle(
                      color: AppColors.primaryCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onExtenderTiempo != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: onExtenderTiempo,
                icon: const Icon(
                  Icons.timer_rounded,
                  color: AppColors.primaryCoral,
                ),
                label: const Text(
                  'Notificar al anfitrión para extender tiempo',
                  style: TextStyle(color: AppColors.primaryCoral),
                ),
              ),
            ],
          ],

          // Motivo de rechazo
          if (!resultado.accesoConcedido &&
              resultado.motivoRechazo != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              resultado.motivoRechazo!,
              style: const TextStyle(
                color: AppColors.actionRed,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // Botón nuevo escaneo
          if (onNuevoEscaneo != null)
            TextButton.icon(
              onPressed: onNuevoEscaneo,
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.headingDark,
              ),
              label: const Text(
                'Nuevo escaneo',
                style: TextStyle(color: AppColors.headingDark),
              ),
            ),
        ],
      ),
    );
  }
}