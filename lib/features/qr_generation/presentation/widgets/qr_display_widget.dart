// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : qr_display_widget.dart
// Módulo    : features/qr_generation/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Widget de visualización del QR — RF-033, RNF-01
// =============================================================================

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/qr_generation_model.dart';

class QrDisplayWidget extends StatelessWidget {
  final QrGenerationModel qr;

  const QrDisplayWidget({super.key, required this.qr});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.baseSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.headingSky),
      ),
      child: Column(
        children: [
          // Nombre del visitante
          Text(
            qr.nombreVisitante,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.deepNavy,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Lugar destino
          Text(
            qr.lugarDestino,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.steelBlue,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Imagen QR
          QrImageView(
            data: qr.codigoQr.isEmpty ? qr.folio : qr.codigoQr,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: AppColors.baseSurface,
          ),
          const SizedBox(height: AppSpacing.md),

          // Código numérico — RNF-01 mínimo 18pt negrita
          const Text(
            'Código de validación:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.neutralGrey,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            qr.codigoNumerico,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.deepNavy,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Vigencia
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: qr.estaVigente
                  ? AppColors.successGreen.withOpacity(0.15)
                  : AppColors.actionRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              qr.estaVigente ? 'Vigente' : 'Vencido',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: qr.estaVigente
                    ? AppColors.successGreen
                    : AppColors.actionRed,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Válido: ${_formatearFecha(qr.vigenciaInicio)} — ${_formatearFecha(qr.vigenciaFin)}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.neutralGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}