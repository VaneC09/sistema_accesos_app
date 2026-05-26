// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : manual_code_dialog.dart
// Módulo    : features/access_control/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-25
// Versión   : 1.0.0
// Descripción: Diálogo para ingreso manual de código — RF-039, RF-033
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/primary_button_widget.dart';

class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog({super.key});

  static Future<String?> mostrar(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ManualCodeDialog(),
    );
  }

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  final _codigoController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  void _onConfirmar() {
    final codigo = _codigoController.text.trim();
    if (codigo.length != 8) {
      setState(() => _error = 'El código debe tener exactamente 8 dígitos');
      return;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(codigo)) {
      setState(() => _error = 'El código solo debe contener dígitos numéricos');
      return;
    }
    Navigator.pop(context, codigo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.baseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      title: const Text(
        'Ingreso manual',
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa el código numérico de 8 dígitos del pase QR\n'
                  '(Ejemplo: si el código es VIS-0491-6013, ingresa 04916013)',
              style: TextStyle(color: AppColors.onyxGrey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              maxLength: 8,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
                color: AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: '04916013',
                errorText: _error,
              ),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            AppStrings.botonCancelar,
            style: TextStyle(color: AppColors.headingDark),
          ),
        ),
        PrimaryButtonWidget(
          texto: AppStrings.botonAceptar,
          onPressed: _onConfirmar,
        ),
      ],
    );
  }
}
