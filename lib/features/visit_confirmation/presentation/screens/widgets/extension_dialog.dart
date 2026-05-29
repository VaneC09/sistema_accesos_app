// =============================================================================
// Proyecto  : Sistema de Gestión de Accesos y Visitas
// Archivo   : extension_dialog.dart
// Módulo    : features/visit_confirmation/presentation/widgets
// Autor     : Omega Company
// Fecha     : 2026-05-29
// Versión   : 1.0.0
// Descripción: Diálogo de decisión cuando el visitante llega fuera de horario
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../notifications/bloc/notification_bloc.dart';
import '../../../../notifications/data/notification_model.dart';
/// Muestra el diálogo y devuelve [true] si el anfitrión autorizó, [false] si
/// denegó, o [null] si cerró sin decidir.
Future<bool?> mostrarDialogoExtension({
  required BuildContext context,
  required NotificationModel notificacion,
  required NotificationBloc notificationBloc,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: notificationBloc,
      child: _ExtensionDialog(notificacion: notificacion),
    ),
  );
}

class _ExtensionDialog extends StatelessWidget {
  final NotificationModel notificacion;

  const _ExtensionDialog({required this.notificacion});

  @override
  Widget build(BuildContext context) {
    final nombre = notificacion.nombreVisitante ?? 'el visitante';
    final folio  = notificacion.folio ?? '—';

    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is ExtensionQrResultado) {
          // Cerrar el diálogo con el resultado
          Navigator.of(context).pop(state.exito);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mensaje),
              backgroundColor:
              state.exito ? AppColors.successGreen : AppColors.actionRed,
            ),
          );
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        ),
        backgroundColor: AppColors.baseSurface,
        contentPadding: const EdgeInsets.all(AppSpacing.lg),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono de alerta
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryCoral.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_off_rounded,
                color: AppColors.primaryCoral,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Título
            const Text(
              'Visitante llegó fuera de horario',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Descripción
            Text(
              '$nombre solicita ingreso fuera del horario programado '
                  '(folio $folio).\n\n'
                  '¿Deseas extender el tiempo de acceso para que el vigilante '
                  'pueda registrar su entrada?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.neutralGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Botones
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                final cargando = state is NotificationLoading;

                return Column(
                  children: [
                    // Autorizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: cargando
                            ? null
                            : () {
                          if (notificacion.idSolicitud == null) {
                            Navigator.of(context).pop(false);
                            return;
                          }
                          context.read<NotificationBloc>().add(
                            AutorizarExtensionQr(
                              idSolicitud:
                              notificacion.idSolicitud!,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium),
                          ),
                        ),
                        icon: cargando
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Icon(Icons.check_circle_rounded),
                        label: Text(
                          cargando ? 'Procesando...' : 'Autorizar extensión',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Denegar
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: cargando
                            ? null
                            : () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.actionRed,
                          side:
                          const BorderSide(color: AppColors.actionRed),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium),
                          ),
                        ),
                        icon: const Icon(Icons.cancel_rounded),
                        label: const Text(
                          'Denegar acceso',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}