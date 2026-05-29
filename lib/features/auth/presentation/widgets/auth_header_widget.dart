// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : auth_header_widget.dart
// Módulo    : features/auth/presentation/extension_dialog.dart
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Encabezado reutilizable de pantallas de auth — MPF-OMEGA-04 §7.2
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class AuthHeaderWidget extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const AuthHeaderWidget({
    super.key,
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icono,
          size: 72,
          color: AppColors.primaryCoral,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}