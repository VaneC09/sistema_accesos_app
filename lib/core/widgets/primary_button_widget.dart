// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : primary_button_widget.dart
// Módulo    : core/extension_dialog.dart
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Botón primario institucional reutilizable — MPF-OMEGA-04 §7.5.1
// =============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

class PrimaryButtonWidget extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;
  final IconData? icono;

  const PrimaryButtonWidget({
    super.key,
    required this.texto,
    this.onPressed,
    this.cargando = false,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.alturaBoton,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: cargando ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCoral,
          foregroundColor: AppColors.baseSurface,
          disabledBackgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
        child: cargando
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: AppColors.baseSurface,
            strokeWidth: 2,
          ),
        )
            : icono != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: AppSpacing.iconoSmall),
            const SizedBox(width: AppSpacing.sm),
            Text(texto),
          ],
        )
            : Text(texto),
      ),
    );
  }
}