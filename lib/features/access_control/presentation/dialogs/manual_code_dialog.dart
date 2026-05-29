// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : manual_code_dialog.dart
// Módulo    : features/access_control/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-28
// Versión   : 1.1.0
// Descripción: Diálogo para ingreso manual de código — RF-039, RF-033
//              Fix: teclado numérico, solo dígitos permitidos
// =============================================================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog._();

  static Future<String?> mostrar(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ManualCodeDialog._(),
    );
  }

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmar() {
    // Solo dígitos — quitar guión si el usuario lo escribió de todos modos
    final limpio = _controller.text.trim().replaceAll('-', '');

    if (limpio.isEmpty) {
      setState(() => _error = 'Ingresa el código');
      return;
    }
    if (limpio.length != 8) {
      setState(() => _error = 'El código debe tener 8 dígitos');
      return;
    }

    // Ensamblar formato VIS-XXXX-XXXX
    final codigoCompleto =
        'VIS-${limpio.substring(0, 4)}-${limpio.substring(4, 8)}';
    Navigator.of(context).pop(codigoCompleto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ingresar código QR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escribe los 8 dígitos del código',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Prefijo fijo no editable
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.headingDark.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: AppColors.headingDark.withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'VIS-',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              // Campo editable: solo 8 dígitos
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  maxLength: 8,
                  keyboardType: TextInputType.number,   // ← teclado numérico
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // ← solo dígitos
                  ],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '00000000',
                    errorText: _error,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.headingDark.withOpacity(0.3),
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _confirmar(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ejemplo: VIS-0491-6013  →  04916013',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _confirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCoral,
          ),
          child: const Text(
            'Verificar',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}