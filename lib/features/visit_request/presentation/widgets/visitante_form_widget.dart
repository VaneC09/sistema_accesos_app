// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : visitante_form_widget.dart
// Módulo    : features/visit_request/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Formulario de visitante individual — RF-013, RF-019
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

class VisitanteFormWidget extends StatelessWidget {
  final int indice;
  final TextEditingController nombreController;
  final TextEditingController correoController;
  final VoidCallback? onEliminar;
  final bool mostrarEliminar;

  const VisitanteFormWidget({
    super.key,
    required this.indice,
    required this.nombreController,
    required this.correoController,
    this.onEliminar,
    this.mostrarEliminar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Visitante ${indice + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepNavy,
                  fontSize: 14,
                ),
              ),
              if (mostrarEliminar)
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    color: AppColors.actionRed,
                  ),
                  onPressed: onEliminar,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Campo nombre
          TextFormField(
            controller: nombreController,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 5) {
                return AppStrings.errorNombreMinimo;
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Campo correo
          TextFormField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return AppStrings.errorCorreoInvalido;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}