// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : confirm_authorization_dialog.dart
// Módulo    : features/visit_authorization/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Diálogo de confirmación de autorización — RF-019, RF-020
// =============================================================================

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';

enum AccionAutorizacion { autorizar, rechazar }

class ConfirmAuthorizationDialog extends StatefulWidget {
  final AccionAutorizacion accion;

  const ConfirmAuthorizationDialog({
    super.key,
    required this.accion,
  });

  static Future<String?> mostrar(
      BuildContext context,
      AccionAutorizacion accion,
      ) {
    return showDialog<String>(
      context: context,
      builder: (_) => ConfirmAuthorizationDialog(accion: accion),
    );
  }

  @override
  State<ConfirmAuthorizationDialog> createState() =>
      _ConfirmAuthorizationDialogState();
}

class _ConfirmAuthorizationDialogState
    extends State<ConfirmAuthorizationDialog> {
  final _motivoController = TextEditingController();

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final esRechazo = widget.accion == AccionAutorizacion.rechazar;

    return AlertDialog(
      backgroundColor: AppColors.baseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      title: Text(
        esRechazo ? 'Rechazar solicitud' : 'Autorizar solicitud',
        style: const TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            esRechazo
                ? '¿Desea rechazar esta solicitud?'
                : '¿Desea autorizar esta solicitud?',
            style: const TextStyle(color: AppColors.onyxGrey),
          ),
          if (esRechazo) ...[
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo del rechazo',
                hintText: 'Ingrese el motivo...',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            AppStrings.botonCancelar,
            style: TextStyle(color: AppColors.headingDark),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              esRechazo ? _motivoController.text : 'autorizado',
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: esRechazo
                ? AppColors.actionRed
                : AppColors.successGreen,
            foregroundColor: AppColors.baseSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
          ),
          child: Text(
            esRechazo ? AppStrings.botonRechazar : AppStrings.botonAutorizar,
          ),
        ),
      ],
    );
  }
}