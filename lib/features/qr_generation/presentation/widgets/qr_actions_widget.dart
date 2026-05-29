// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_actions_widget.dart
// Módulo    : features/qr_generation/presentation/extension_dialog.dart
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Widget de acciones del QR — RF-036, RF-037, RF-038
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../data/qr_generation_model.dart';

class QrActionsWidget extends StatelessWidget {
  final QrGenerationModel qr;
  final VoidCallback? onEnviar;
  final VoidCallback? onReenviar;
  final VoidCallback? onExtender;
  final bool cargando;

  const QrActionsWidget({
    super.key,
    required this.qr,
    this.onEnviar,
    this.onReenviar,
    this.onExtender,
    this.cargando = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Contador de reenvíos
        Text(
          'Reenvíos: ${qr.reenvios}/${qr.maxReenvios}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutralGrey,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Botón enviar
        PrimaryButtonWidget(
          texto: AppStrings.botonEnviar,
          icono: Icons.send_rounded,
          cargando: cargando,
          onPressed: onEnviar,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Botón reenviar
        SizedBox(
          height: AppSpacing.alturaBoton,
          child: ElevatedButton.icon(
            onPressed: qr.puedeReenviar && !cargando ? onReenviar : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.headingDark,
              foregroundColor: AppColors.baseSurface,
              disabledBackgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              qr.puedeReenviar
                  ? 'Reenviar QR'
                  : AppStrings.limiteReenvios,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Botón extender vigencia
        if (!qr.estaVigente) ...[
          SizedBox(
            height: AppSpacing.alturaBoton,
            child: OutlinedButton.icon(
              onPressed: !cargando ? onExtender : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryCoral,
                side: const BorderSide(color: AppColors.primaryCoral),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
              ),
              icon: const Icon(Icons.timer_rounded),
              label: const Text('Extender vigencia'),
            ),
          ),
        ],
      ],
    );
  }
}