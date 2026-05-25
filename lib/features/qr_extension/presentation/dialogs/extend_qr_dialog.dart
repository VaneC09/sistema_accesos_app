// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : extend_qr_dialog.dart
// Módulo    : features/qr_extension/presentation/dialogs
// Autor     : Omega Company
// Fecha     : 2026-05-23
// Versión   : 1.0.0
// Descripción: Diálogo de extensión de QR — RF-018, RF-038
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/primary_button_widget.dart';
import '../../bloc/qr_extension_bloc.dart';
import '../../data/qr_extension_repository.dart';

class ExtendQrDialog extends StatefulWidget {
  final int idSolicitud;

  const ExtendQrDialog({
    super.key,
    required this.idSolicitud,
  });

  static Future<bool?> mostrar(
      BuildContext context,
      int idSolicitud,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => BlocProvider(
        create: (_) => QrExtensionBloc(
          repository: QrExtensionRepository(),
        ),
        child: ExtendQrDialog(idSolicitud: idSolicitud),
      ),
    );
  }

  @override
  State<ExtendQrDialog> createState() => _ExtendQrDialogState();
}

class _ExtendQrDialogState extends State<ExtendQrDialog> {
  int _minutosExtra = 15;

  final List<int> _opciones = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrExtensionBloc, QrExtensionState>(
      listener: (context, state) {
        if (state is QrExtensionSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.exitoExtensionQr),
              backgroundColor: AppColors.successGreen,
            ),
          );
        } else if (state is QrExtensionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor: AppColors.actionRed,
            ),
          );
        }
      },
      child: AlertDialog(
        backgroundColor: AppColors.baseSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        title: const Text(
          'Extender vigencia QR',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuántos minutos desea extender la vigencia del pase QR?',
              style: TextStyle(color: AppColors.onyxGrey),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<int>(
              value: _minutosExtra,
              decoration: const InputDecoration(
                labelText: 'Minutos extra',
                prefixIcon: Icon(Icons.timer_rounded),
              ),
              items: _opciones
                  .map((m) => DropdownMenuItem(
                value: m,
                child: Text('$m minutos'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => _minutosExtra = value ?? 15);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              AppStrings.botonCancelar,
              style: TextStyle(color: AppColors.headingDark),
            ),
          ),
          BlocBuilder<QrExtensionBloc, QrExtensionState>(
            builder: (context, state) {
              return PrimaryButtonWidget(
                texto: 'Extender',
                cargando: state is QrExtensionLoading,
                onPressed: () {
                  context.read<QrExtensionBloc>().add(
                    ExtenderVigenciaQr(
                      idSolicitud: widget.idSolicitud,
                      minutosExtra: _minutosExtra,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}