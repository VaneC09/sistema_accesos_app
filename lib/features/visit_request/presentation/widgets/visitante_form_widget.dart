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
  final TextEditingController apellidosController;
  final TextEditingController correoController;
  final VoidCallback? onEliminar;
  final bool mostrarEliminar;

  const VisitanteFormWidget({
    super.key,
    required this.indice,
    required this.nombreController,
    required this.apellidosController,
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
          TextFormField(
            controller: nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre(s)',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'Ingrese el nombre (mínimo 2 caracteres)';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: apellidosController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) {
              if (value == null || value.trim().length < 2) {
                return 'Ingrese los apellidos (mínimo 2 caracteres)';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: correoController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo electrónico',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.errorCorreoInvalido;
              }
              final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w+$');
              if (!regex.hasMatch(value.trim())) {
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