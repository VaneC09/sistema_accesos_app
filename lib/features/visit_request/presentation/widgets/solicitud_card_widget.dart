// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : solicitud_card_widget.dart
// Módulo    : features/visit_request/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Tarjeta de solicitud de visita — RF-017
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/visit_request_model.dart';

class SolicitudCardWidget extends StatelessWidget {
  final VisitRequestModel solicitud;
  final VoidCallback? onTap;

  const SolicitudCardWidget({
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
          border: Border.all(color: AppColors.surface),
          boxShadow: [
            BoxShadow(
              color: AppColors.surface,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Indicador de estado
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: _colorEstado(solicitud.estado),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      _ChipEstado(estado: solicitud.estado),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    solicitud.lugarDestino,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.neutralGrey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatearFecha(solicitud.fechaVisita),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.steelBlue,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutralGrey,
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
        return AppColors.warningOrange;
      case 'rechazada':
      case 'cancelada':
        return AppColors.actionRed;
      default:
        return AppColors.headingSky;
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}

class _ChipEstado extends StatelessWidget {
  final String estado;

  const _ChipEstado({required this.estado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _colorFondo(estado),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        estado,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _colorTexto(estado),
        ),
      ),
    );
  }

  Color _colorFondo(String estado) {
    switch (estado.toLowerCase()) {
      case 'autorizada':
        return AppColors.successGreen.withOpacity(0.15);
      case 'pendiente':
        return AppColors.warningOrange.withOpacity(0.15);
      case 'rechazada':
      case 'cancelada':
        return AppColors.actionRed.withOpacity(0.15);
      default:
        return AppColors.headingSky.withOpacity(0.15);
    }
  }

  Color _colorTexto(String estado) {
    switch (estado.toLowerCase()) {
      case 'autorizada':
        return AppColors.successGreen;
      case 'pendiente':
        return AppColors.primaryCoral;
      case 'rechazada':
      case 'cancelada':
        return AppColors.actionRed;
      default:
        return AppColors.headingDark;
    }
  }
}